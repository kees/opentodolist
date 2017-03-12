#include "todolist.h"

#include "todo.h"
#include "fileutils.h"


/**
 * @brief Constructor.
 */
TodoList::TodoList(QObject* parent) : TodoList(QString(), parent)
{
}

/**
 * @brief Constructor.
 */
TodoList::TodoList(const QString& filename, QObject* parent) : TopLevelItem(filename, parent)
{
}

/**
 * @brief Destructor.
 */
TodoList::~TodoList()
{
}
