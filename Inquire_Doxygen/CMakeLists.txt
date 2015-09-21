cmake_minimum_required (VERSION 3.0.0)
project (DoxygenTestProject)

include(${CMAKE_CURRENT_LIST_DIR}/../../Inquire/Inquire.cmake)

set(IPM_install_Doxygen ON CACHE BOOL "")

# an APM module repository is a place (folder, GIT repo, etc.) containing CMake modules to "require" projects.
inquire_add_module_repository(moduleRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../")

# an APM package repository contains all the built libraries and sources.
inquire_add_package_repository(packageRepo FOLDER "${CMAKE_CURRENT_BINARY_DIR}/packages/")

require_package(Doxygen VERSION 1.8.10 REQUIRED)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
add_doxygen_target("${CMAKE_CURRENT_BINARY_DIR}/Doxyfile" doc "${CMAKE_CURRENT_BINARY_DIR}/doc")
