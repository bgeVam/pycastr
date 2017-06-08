project(com.github.bgeVam.pycastr)

    cmake_minimum_required(VERSION 2.6)

    list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

    set(DATADIR "${CMAKE_INSTALL_PREFIX}/share")
    set(PKGDATADIR "${DATADIR}/com.github.bgeVam.pycastr")
    set(EXEC_NAME "com.github.bgeVam.pycastr")
    set(RELEASE_NAME "pycastr")
    set(VERSION "0.1")
    set(VERSION_INFO "alpha")

    find_package(PkgConfig)
    pkg_check_modules(DEPS REQUIRED 
        gtk+-3.0 
        gee-0.8 
        appindicator3-0.1
        libnotify
    )

    add_definitions(${DEPS_CFLAGS})
    link_libraries(${DEPS_LIBRARIES})
    link_directories(${DEPS_LIBRARY_DIRS})
    find_package(Vala REQUIRED)
    include(ValaVersion)
    ensure_vala_version("0.22.0" MINIMUM)

    include(ValaPrecompile)
    vala_precompile(VALA_C ${EXEC_NAME}
        src/pycastr-gtk/Client.vala
        src/pycastr-gtk/ClientService.vala
        src/pycastr-gtk/PycastrGtk.vala
        src/pycastr-gtk/PycastrIndicator.vala
    PACKAGES
        gtk+-3.0
        gee-0.8
        appindicator3-0.1
        libnotify
    )
    add_executable(${EXEC_NAME} ${VALA_C})

    # install the python dependencies
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/pycastr.py DESTINATION /opt/pycastr/src)

    # install icons and update cache
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/pycastr-status-on.svg DESTINATION ${DATADIR}/icons/hicolor/22x22/apps/)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/pycastr-status-off.svg DESTINATION ${DATADIR}/icons/hicolor/22x22/apps/)
    install(CODE "execute_process(COMMAND gtk-update-icon-cache -f -q -t ${DATADIR}/icons/hicolor ERROR_QUIET)")

    # install the binaries
    install(TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

    # install .desktop file for Applications menu
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.desktop DESTINATION ${DATADIR}/applications/)

    # install .appdata.xml file for AppCenter
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.appdata.xml DESTINATION ${DATADIR}/metainfo/)

    # add .desktop file to autostart
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.desktop DESTINATION ~/.config/autostart/)
