 # project name
    project (com.github.bgeVam.pycastr)

    # the oldest stable cmake version we support
    cmake_minimum_required (VERSION 2.6)

    # tell cmake where its modules can be found in our project directory
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
    list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/src)

    # where we install data directory (if we have any)
    set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

    # what to call that directory where we install data too
    set (PKGDATADIR "${DATADIR}/com.github.bgeVam.pycastr")

    set (EXEC_NAME "com.github.bgeVam.pycastr")
    set (RELEASE_NAME "pycastr")
    set (VERSION "0.1")
    set (VERSION_INFO "alpha")

    # we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
    find_package(PkgConfig)

    # now let's actually check for the required dependencies
    pkg_check_modules(DEPS REQUIRED 
        gtk+-3.0 
        gee-0.8 
        appindicator3-0.1
        libnotify
        python3
    )

    add_definitions(${DEPS_CFLAGS})
    link_libraries(${DEPS_LIBRARIES})
    link_directories(${DEPS_LIBRARY_DIRS})

    # make sure we have vala
    find_package(Vala REQUIRED)
    # make sure we use vala
    include(ValaVersion)
    # make sure it's the desired version of vala
    ensure_vala_version("0.22.0" MINIMUM)

    # files we want to compile
    include(ValaPrecompile)
    vala_precompile(VALA_C ${EXEC_NAME}
        src/pycastr-gtk/Client.vala
        src/pycastr-gtk/ClientService.vala
        src/pycastr-gtk/PycastrGtk.vala
        src/pycastr-gtk/PycastrIndicator.vala

    # tell what libraries to use when compiling
    PACKAGES
        gtk+-3.0
        gee-0.8
        appindicator3-0.1
        libnotify
    )

    # tell cmake what to call the executable we just made
    add_executable(${EXEC_NAME} ${VALA_C})

    # install the python dependencies
    file(MAKE_DIRECTORY /tmp/pycastr)
    file(COPY src/pycastr.py DESTINATION /tmp/pycastr/src)
    # TODO add python-pip3 as requirement
    install(CODE "execute_process (COMMAND pip3 install netdisco)")
    install(CODE "execute_process (COMMAND pip3 install kodi-json)")

    # install icons and update cache
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/pycastr-status-on.svg DESTINATION ${DATADIR}/icons/hicolor/24x24/apps/)
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/pycastr-status-off.svg DESTINATION ${DATADIR}/icons/hicolor/24x24/apps/)
    install(CODE "execute_process(COMMAND gtk-update-icon-cache -f -q -t ${DATADIR}/icons/hicolor ERROR_QUIET)")

    # install the binaries we just made
    install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

    # install our .desktop file so the Applications menu will see it
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.desktop DESTINATION ${DATADIR}/applications/)

    # install our .appdata.xml file so AppCenter will see it
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.appdata.xml DESTINATION ${DATADIR}/metainfo/)

    # add our .desktop file to the autostart
    install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.bgeVam.pycastr.desktop DESTINATION ~/.config/autostart/)
