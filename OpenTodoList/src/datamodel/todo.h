/*
 *  OpenTodoList - A todo and task manager
 *  Copyright (C) 2013, 2014  Martin Höher <martin@rpdev.net>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ABSTRACTTODO_H
#define ABSTRACTTODO_H

#include "core/opentodolistinterfaces.h"

#include <QObject>
#include <QPointer>

namespace OpenTodoList {

namespace DataModel {

class Todo : public QObject, public ITodo
{
    Q_OBJECT
    Q_PROPERTY( double weight READ weight WRITE setWeight NOTIFY weightChanged )
    Q_PROPERTY( int progress READ progress WRITE setProgress NOTIFY progressChanged )
    Q_PROPERTY( int priority READ priority WRITE setPriority NOTIFY priorityChanged )
    Q_PROPERTY( QUuid parentTodoUuid READ parentTodoUuid CONSTANT )
    Q_PROPERTY( QUuid todoListUuid READ todoListUuid CONSTANT )
    Q_PROPERTY( QDateTime dueDate READ dueDate WRITE setDueDate NOTIFY dueDateChanged )
    Q_PROPERTY( QString title READ title WRITE setTitle NOTIFY titleChanged )
    Q_PROPERTY( QString description READ description WRITE setDescription NOTIFY descriptionChanged )
    Q_PROPERTY( bool isDeleted READ isDeleted WRITE setDeleted NOTIFY deletedChanged )
    Q_PROPERTY( bool isDone READ isDone NOTIFY progressChanged )
    Q_PROPERTY( QDateTime lastModificationTime READ lastModificationTime WRITE setLastModificationTime NOTIFY lastModificationTimeChanged)

public:

    explicit Todo( QObject* parent = 0 );
    virtual ~Todo();

    bool isNull() const;
    bool isDone() const;

    // ITodo interface
public:
    const QUuid &uuid() const override;
    void setUuid(const QUuid &uuid) override;
    double weight() const override;
    void setWeight(double weight) override;
    int progress() const override;
    void setProgress(int progress) override;
    int priority() const override;
    void setPriority(int priority) override;
    const QUuid& parentTodoUuid() const override;
    void setParentTodoUuid(const QUuid &uuid) override;
    const QUuid& todoListUuid() const override;
    void setTodoListUuid(const QUuid &uuid) override;
    const QDateTime &dueDate() const override;
    void setDueDate(const QDateTime &dueOn) override;
    const QString &title() const override;
    void setTitle(const QString &title) override;
    const QString &description() const override;
    void setDescription(const QString &description) override;
    bool isDeleted() const override;
    void setDeleted(bool isDeleted) override;
    const QStringList metaAttributeKeys() const override;
    const QVariant metaAttribute(const QString &key) const override;
    void setMetaAttribute(const QString &key, const QVariant &value) override;
    bool hasMetaAttribute(const QString &key) const override;
    void deleteMetaAttribute(const QString &key) override;
    QDateTime lastModificationTime() const override;
    void setLastModificationTime(const QDateTime &dateTime) override;
    bool disposed() const override;


signals:

    void uuidChanged();
    void weightChanged();
    void progressChanged();
    void priorityChanged();
    void dueDateChanged();
    void titleChanged();
    void descriptionChanged();
    void deletedChanged();
    void lastModificationTimeChanged();

    void changed();
    void reset();

    
public slots:

    void toggle();

protected:

private:

    int                       m_previousProgress;

    void setupTodo();

private:

    // ITodo properties
    QUuid                   m_uuid;
    double                  m_weight;
    int                     m_progress;
    int                     m_priority;
    QUuid                   m_parentUuid;
    QUuid                   m_todoListUuid;
    QDateTime               m_dueDate;
    QString                 m_title;
    QString                 m_description;
    bool                    m_deleted;
    QVariantMap             m_metaAttributes;
    QDateTime               m_lastModificationTime;
    bool                    m_isPermanentlyDeleted;

};

} /* DataModel */

} /* OpenTodoList */

#endif // ABSTRACTTODO_H
