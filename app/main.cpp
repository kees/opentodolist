#include "opentodolistqmlextensionsplugin.h"

#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileSystemWatcher>
#include <QFont>
#include <QFontInfo>
#include <QIcon>
#include <QLocale>
#include <QLoggingCategory>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QSslSocket>
#include <QTranslator>

#ifdef OTL_USE_SINGLE_APPLICATION
#include "singleapplication.h"
#else
#include <QGuiApplication>
#endif

#include <iostream>


class QmlFileSystemWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool modified READ modified NOTIFY modifiedChanged)

public:

    QmlFileSystemWatcher(const QString baseUrl, QQmlApplicationEngine *engine, QObject *parent = 0) :
        QObject(parent),
        m_baseUrl(baseUrl),
        m_engine(engine),
        m_modified(false)
  #ifdef OPENTODOLIST_DEBUG
      , m_watcher(new QFileSystemWatcher(this))
  #endif
    {
        Q_CHECK_PTR(m_engine);
#ifdef OPENTODOLIST_DEBUG
        if (QDir(m_baseUrl).exists()) {
            watchPath();
            connect(m_watcher, &QFileSystemWatcher::fileChanged, [this](const QString &file) {
                qDebug() << "File" << file << "has changed.";
                m_modified = true;
                watchPath();
                emit modifiedChanged();
            });
            connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](const QString &dir) {
                m_modified = true;
                qDebug() << "Directory" << dir << "has changed.";
                watchPath();
                emit modifiedChanged();
            });
        }
#endif
    }

    bool modified() const { return m_modified; }

public slots:

    void reload() {
#ifdef OPENTODOLIST_DEBUG
        m_engine->clearComponentCache();
        m_engine->load(QUrl(m_baseUrl + "main.qml"));
        m_modified = false;
        emit modifiedChanged();
#endif
    }

signals:

    void modifiedChanged();

private:

    QString                 m_baseUrl;
    QQmlApplicationEngine  *m_engine;
    bool                    m_modified;
#ifdef OPENTODOLIST_DEBUG
    QFileSystemWatcher     *m_watcher;
#endif

    void watchPath() {
#ifdef OPENTODOLIST_DEBUG
        if (!m_watcher->directories().isEmpty()) {
            m_watcher->removePaths(m_watcher->directories());
        }
        if (!m_watcher->files().isEmpty()) {
            m_watcher->removePaths(m_watcher->files());
        }
        m_watcher->addPath(m_baseUrl);
        QDirIterator it(m_baseUrl, QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            QString entry = it.next();
            m_watcher->addPath(entry);
        }
#endif
    }

};


int main(int argc, char *argv[])
{
#ifdef OPENTODOLIST_IS_APPIMAGE
    // In the current AppImage build, we do not deploy the
    // Qt wayland plugin. Hence, fall back to x11/xcb.
    auto platform = qgetenv("QT_QPA_PLATFORM");
    if (platform == "wayland") {
        qputenv("QT_QPA_PLATFORM", "xcb");
    }
#endif

    //qputenv("QT_QUICK_CONTROLS_STYLE", "material");

    // Let the app decide which scale factor to apply
#ifdef Q_OS_ANDROID
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");
#endif

    //qSetMessagePattern("%{file}(%{line}): %{message}");
#ifdef OPENTODOLIST_DEBUG
    QLoggingCategory(0).setEnabled(QtDebugMsg, true);
#endif

#ifdef OTL_USE_SINGLE_APPLICATION
    SingleApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    app.setAttribute(Qt::AA_EnableHighDpiScaling);

    QTranslator translator;
    // look up e.g. :/translations/myapp_de.qm

    {
        auto l = QLocale();
        auto uiLanguages = l.uiLanguages();
        for (auto uiLanguage : uiLanguages) {
            QString fileName = ":/translations/opentodolist_" + uiLanguage;
            if (translator.load(fileName, QString(), "-", ".qm")) {
                qDebug() << "Found translation for" << uiLanguage;
                break;
            }
        }
    }

    QCoreApplication::setApplicationName("OpenTodoList");
    QCoreApplication::setApplicationVersion(OPENTODOLIST_VERSION);
    QCoreApplication::setOrganizationDomain("www.rpdev.net");
    QCoreApplication::setOrganizationName("RPdev");

    app.setWindowIcon(QIcon(":/res/OpenTodoList80.png"));

    QCommandLineParser parser;
    parser.setApplicationDescription(
                QCoreApplication::translate("main", "Manage your personal data."));
    parser.addHelpOption();
    parser.addVersionOption();

#ifdef OPENTODOLIST_DEBUG
    QCommandLineOption qmlRootOption = {{"Q", "qml-root"},
                                        QCoreApplication::translate("main", "QML Root Directory"),
                                        QCoreApplication::translate("main", "DIR")};
    parser.addOption(qmlRootOption);
#endif

    // Enable touch screen optimizations
    QCommandLineOption enableTouchOption = {{"T", "enable-touch"},
                                            QCoreApplication::translate(
                                            "main",
                                            "Switch on some optimizations for touchscreens.")};
    parser.addOption(enableTouchOption);

    // If APPDIR is set, assume we are running from AppImage.
    // Provide option to remove desktop integration. Note that we
    // don't handle this; instead it is handled by the `desktopintegration`
    // script we use.
    // See https://github.com/AppImage/AppImageKit/blob/master/desktopintegration.
#ifdef OPENTODOLIST_IS_APPIMAGE
    QCommandLineOption removeDesktopIntegrationOption = {
        "remove-appimage-desktop-integration",
        QCoreApplication::translate(
        "main",
        "Remove shortcuts to the AppImage.")
    };
    parser.addOption(removeDesktopIntegrationOption);

#endif

    parser.process(app);

    QQmlApplicationEngine engine;
    QString qmlBase = "qrc:/";

#ifdef OPENTODOLIST_DEBUG
    if (parser.isSet(qmlRootOption)) {
        qmlBase = QDir(parser.value(qmlRootOption)).canonicalPath() + "/";
        if (!QFile::exists(qmlBase + "main.qml")) {
            qFatal("File main.qml does not exist in %s, probably not a valid OpenTodoList QML dir!",
                   qUtf8Printable(qmlBase));
        }
    }
#endif

    engine.addImportPath(qmlBase);
    OpenTodoListQmlExtensionsPlugin plugin;
    plugin.registerTypes("OpenTodoList");

#ifdef OPENTODOLIST_DEBUG
    QmlFileSystemWatcher watcher(qmlBase, &engine);
    engine.rootContext()->setContextProperty("qmlFileSystemWatcher", &watcher);
#endif


    engine.rootContext()->setContextProperty("debugMode",
                                             QVariant(
                                             #ifdef OPENTODOLIST_DEBUG
                                                 true
                                             #else
                                                 false
                                             #endif
                                                 )
                                             );

    // Enable touch optimizations, this flag is controlled via CLI, additionally, it
    // is set implicitly on some platforms:
    {
        bool enableTouchOptimizations =
        #if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_QNX) || defined(Q_OS_WINPHONE)
                true
        #else
                false
        #endif
                ;
        if (parser.isSet(enableTouchOption))
        {
            enableTouchOptimizations = true;
        }
        engine.rootContext()->setContextProperty("enableTouchOptimizations",
                                                 enableTouchOptimizations);
    }
#ifdef OTL_USE_SINGLE_APPLICATION
    engine.rootContext()->setContextProperty("application", &app);
#endif
    engine.rootContext()->setContextProperty(
                "applicationVersion", QVariant(OPENTODOLIST_VERSION));
    engine.rootContext()->setContextProperty(
                "defaultFontPixelSize", QFontInfo(QFont()).pixelSize());
    engine.rootContext()->setContextProperty(
                "qmlBaseDirectory", qmlBase);
    engine.load(QUrl(qmlBase + "main.qml"));

    // Print SSL information for debugging
    qWarning() << "OpenSSL version Qt was built against:"
               << QSslSocket::sslLibraryBuildVersionString();
    qWarning() << "OpenSSL version loaded:"
               << QSslSocket::sslLibraryVersionString();

    return app.exec();
}

#include "main.moc"
