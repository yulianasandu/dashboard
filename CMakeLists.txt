cmake_minimum_required(VERSION 3.16)

project(dashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appdashboard
    main.cpp
    carcontroller.cpp
    carcontroller.h
)

qt_add_qml_module(appdashboard
    URI dashboard
    VERSION 1.0
    QML_FILES
        Main.qml

    RESOURCES
        icons/oil_pressure.svg
        icons/check_engine.svg
        icons/battery.svg
        icons/low_beam.svg
        icons/high_beam.svg
        icons/coolant_temp.svg
        icons/fog_front.svg
        icons/turn_left.svg
        icons/turn_right.svg
        icons/side_lamps.svg
        icons/fog_rear.svg
        icons/fuel_low.svg
        icons/fuel.svg
        icons/abs.svg
        icons/brake_system.svg
        icons/esc_off.svg
        icons/trunk_open.svg
        icons/power_steering.svg
        icons/hood_open.svg
        icons/seatbelt.svg
        icons/door_open.svg
        icons/master_warning.svg

        fonts/eurostile.ttf
        SOURCES canreceiver.h canreceiver.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appdashboard PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appdashboard
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appdashboard
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appdashboard
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
