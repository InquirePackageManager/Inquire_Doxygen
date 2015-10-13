inquire_message(INFO "Triggering installation of Doxygen in version ${Doxygen_VERSION}... ")

#---------------------------------------------------------------------------------------#
#-										DOWNLOAD									   -#
#---------------------------------------------------------------------------------------#
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(l_IPM_archive_name "doxygen-${Doxygen_VERSION}.windows.bin.zip")
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(l_IPM_archive_name "doxygen-${Doxygen_VERSION}.linux.bin.tar.gz")
else()
  inquire_message(FATAL_ERROR "OS ${CMAKE_SYSTEM_NAME} not yet supported.")
endif()
set(l_IPM_doxygen_location "ftp://ftp.stack.nl/pub/users/dimitri/${l_IPM_archive_name}")
set(l_IPM_doxygen_local_dir ${Doxygen_PACKAGE_ROOT}/${Doxygen_VERSION})
set(l_IPM_doxygen_local_archive "${l_IPM_doxygen_local_dir}/download/${l_IPM_archive_name}")

if(NOT EXISTS "${l_IPM_doxygen_local_archive}")
	inquire_message(INFO "Downloading Doxygen ${Doxygen_VERSION} from ${l_IPM_doxygen_location}.")
	file(DOWNLOAD "${l_IPM_doxygen_location}" "${l_IPM_doxygen_local_archive}" SHOW_PROGRESS STATUS l_IPM_download_status)
	list(GET l_IPM_download_status 0 l_IPM_download_status_code)
	list(GET l_IPM_download_status 1 l_IPM_download_status_string)
	if(NOT l_IPM_download_status_code EQUAL 0)
		inquire_message(FATAL_ERROR "Error: downloading ${l_IPM_doxygen_location} failed with error : ${l_IPM_download_status_string}")
	endif()
else()
		inquire_message(INFO "Using already downloaded Doxygen version from ${l_IPM_doxygen_local_archive}")
endif()

#---------------------------------------------------------------------------------------#
#-										EXTRACT 									   -#
#---------------------------------------------------------------------------------------#

inquire_message(INFO "Extracting Doxygen ${Doxygen_VERSION}...")
file(MAKE_DIRECTORY ${l_IPM_doxygen_local_dir}/install/)
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${l_IPM_doxygen_local_archive} WORKING_DIRECTORY ${l_IPM_doxygen_local_dir}/install/)
inquire_message(INFO "Extracting Doxygen ${Doxygen_VERSION}... DONE.")

#---------------------------------------------------------------------------------------#
#-										GENERATE INCLUDE FILE 									   -#
#---------------------------------------------------------------------------------------#

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(l_IPM_doxygen_executable "${l_IPM_doxygen_local_dir}/install/doxygen.exe")
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(l_IPM_archive_name "${l_IPM_doxygen_local_dir}/install/doxygen-${l_Doxygen_VERSION_dir}/bin/doxygen")
else()
  inquire_message(FATAL_ERROR "OS ${CMAKE_SYSTEM_NAME} not yet supported.")
endif()

file(WRITE ${l_IPM_doxygen_local_dir}/include/doxygen.cmake
"function(add_doxygen_target a_IPM_doxyfile a_IPM_target_name a_IPM_doc_folder)
  if(NOT EXISTS \${a_IPM_doc_folder})
    file(MAKE_DIRECTORY \${a_IPM_doc_folder})
  endif()
  add_custom_target(\${a_IPM_target_name}
    \"${l_IPM_doxygen_executable}\" \${a_IPM_doxyfile}
    WORKING_DIRECTORY \${a_IPM_doc_folder})
endfunction()"
)


set(Doxygen_PACKAGE_VERSION_ROOT ${l_IPM_doxygen_local_dir})
