#include "opentodolistqmlextensionsplugin.h"

#include <QCommandLineParser>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFont>
#include <QFontInfo>
#include <QFontDatabase>
#include <QIcon>
#include <QLocale>
#include <QLoggingCategory>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScreen>
#include <QSslSocket>
#include <QTranslator>
#include <QSysInfo>

#ifdef OTL_USE_SINGLE_APPLICATION
#include "singleapplication.h"
#else
#include <QApplication>
#endif

#include <iostream>

#include "../lib/opentodolist_version.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    
#ifdef OPENTODOLIST_IS_APPIMAGE
    // In the current AppImage build, we do not deploy the
    // Qt wayland plugin. Hence, fall back to x11/xcb.
    auto platform = qgetenv("QT_QPA_PLATFORM");
    if (platform == "wayland") {
        qputenv("QT_QPA_PLATFORM", "xcb");
    }
#endif

    // Let the app decide which scale factor to apply
#ifdef Q_OS_ANDROID
    qputenv("QT_AUTO_SCREEN_SCALE_FACTOR", "1");
#endif

    //qSetMessagePattern("%{file}(%{line}): %{message}");
#ifdef OPENTODOLIST_DEBUG
    QLoggingCategory(nullptr).setEnabled(QtDebugMsg, true);
#endif

#ifdef OTL_USE_SINGLE_APPLICATION
    SingleApplication app(argc, argv, false,
                          SingleApplication::User |
                          SingleApplication::ExcludeAppPath);
#else
    QGuiApplication app(argc, argv);
#endif

    // Load color emoji font:
    QFontDatabase::addApplicationFont(
                ":/Fonts/NotoColorEmoji-unhinted/NotoColorEmoji.ttf");

    // Use Noto Color Emoji as substitution font for color emojies:
    // {
    //     const auto FontTypes = {
    //         QFontDatabase::GeneralFont,
    //         QFontDatabase::FixedFont,
    //         QFontDatabase::TitleFont,
    //         QFontDatabase::SmallestReadableFont
    //     };
    //     for (auto fontType : FontTypes) {
    //         auto font = QFontDatabase::systemFont(fontType);
    //         QFont::insertSubstitution(font.family(), "Noto Color Emoji");
    //     }
    // }
    #ifdef OPENTODOLIST_FLATPAK
    {
        QDir dir("/var/config/fontconfig/conf.d");
        if (dir.mkpath(".")) {
            QFile::copy("/app/etc/fonts/conf.d/90-otl-color-emoji.conf",
            dir.absoluteFilePath("90-otl-color-emoji.conf"));
        }
    }
    #endif

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

#ifdef OTL_USE_SINGLE_APPLICATION
    engine.rootContext()->setContextProperty("application", &app);
#endif
    engine.rootContext()->setContextProperty(
                "applicationVersion", QVariant(OPENTODOLIST_VERSION));
    engine.rootContext()->setContextProperty(
                "defaultFontPixelSize", QFontInfo(QFont()).pixelSize());
    engine.rootContext()->setContextProperty(
                "qmlBaseDirectory", qmlBase);
#ifdef OPENTODOLIST_DEBUG
    engine.rootContext()->setContextProperty("isDebugBuild", true);
#else
    engine.rootContext()->setContextProperty("isDebugBuild", false);
#endif
    engine.load(QUrl(qmlBase + "main.qml"));

    // Print diagnostic information
    qWarning() << "System ABI:" << QSysInfo::buildAbi();
    qWarning() << "Build CPU Architecture:" << QSysInfo::buildCpuArchitecture();
    qWarning() << "Current CPU Architecture:"
               << QSysInfo::currentCpuArchitecture();
    qWarning() << "Kernel Type:" << QSysInfo::kernelType();
    qWarning() << "Kernel Version:" << QSysInfo::kernelVersion();
    qWarning() << "Product Name:" << QSysInfo::prettyProductName();

    // Print SSL information for debugging
    qWarning() << "OpenSSL version Qt was built against:"
               << QSslSocket::sslLibraryBuildVersionString();
    qWarning() << "OpenSSL version loaded:"
               << QSslSocket::sslLibraryVersionString();

    return app.exec();
}
