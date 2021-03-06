# Set application version:
if(OPENTODOLIST_FORCE_VERSION)
    add_definitions(-DOPENTODOLIST_VERSION="${OPENTODOLIST_FORCE_VERSION}")
else()
    set(OPENTODOLIST_MAJOR 3)
    set(OPENTODOLIST_MINOR 10)
    set(OPENTODOLIST_PATCH 0)
    set(OPENTODOLIST_VERSION
        ${OPENTODOLIST_MAJOR}.${OPENTODOLIST_MINOR}.${OPENTODOLIST_PATCH})
    find_program(GIT_EXECUTABLE git)
    if(GIT_EXECUTABLE)
        execute_process(
            COMMAND
                ${GIT_EXECUTABLE} describe --tags
            OUTPUT_VARIABLE
                OPENTODOLIST_GIT_VERSION_STRING
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        add_definitions(-DOPENTODOLIST_VERSION="${OPENTODOLIST_GIT_VERSION_STRING}")
    else()
        add_definitions(-DOPENTODOLIST_VERSION="${OPENTODOLIST_VERSION}-unknown")
    endif()
endif()
