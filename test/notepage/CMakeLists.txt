find_package(Qt5Test REQUIRED)
add_executable(
    test_notepage

    test_notepage.cpp
)

target_link_libraries(
    test_notepage

    # Internal libraries:
    opentodolist-common

    # Qt Libraries
    Qt5::Test
)

add_test(
    NAME notepage
    COMMAND $<TARGET_FILE:test_notepage> -platform minimal
)
