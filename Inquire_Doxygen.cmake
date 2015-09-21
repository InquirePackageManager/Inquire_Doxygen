function(check_package_compatibility a_IPM_result)
  set(${a_IPM_result} TRUE PARENT_SCOPE)
endfunction()

function(get_compatible_package_version_root a_IPM_package_root a_IPM_version a_IPM_result)
	IPM_get_compatible_package_version_root_parse_arguments(l_IPM_get_compatible_package_version_root ${ARGN})
	IPM_get_subdirectories(${a_IPM_package_root} l_IPM_version_dirs)

	#try to find a matching version
	foreach(l_IPM_version_dir ${l_IPM_version_dirs})
		set(l_IPM_version_compatible FALSE)
    #if the doxygen executable file exists, the installation is valid.
    #NOTE : on linux, the packaging is in an inner folder named bin. On windows, executable are at the root...
		if(EXISTS ${a_IPM_package_root}/${l_IPM_version_dir}/doxygen.exe OR EXISTS ${a_IPM_package_root}/${l_IPM_version_dir}/doxygen-${l_IPM_version_dir}/bin/doxygen)
			if(${l_IPM_version_dir} VERSION_EQUAL ${a_IPM_version})
				set(l_IPM_version_compatible TRUE)
				set(${a_IPM_result} ${a_IPM_package_root}/${l_IPM_version_dir} PARENT_SCOPE)
				break()
			else()
				#we assume that greater versions are backward compatible
				if(${l_IPM_version_dir} VERSION_GREATER ${a_IPM_version} AND NOT ${l_IPM_get_compatible_package_version_root_EXACT})
					set(l_IPM_version_compatible TRUE)
					set(${a_IPM_result} ${a_IPM_package_root}/${l_IPM_version_dir} PARENT_SCOPE)
					break()
				endif()
			endif()
		endif()
	endforeach()
endfunction()

function(download_package_version a_IPM_package_root a_IPM_result a_IPM_version)
	inquire_message(INFO "Triggering installation of Doxygen in version ${a_IPM_version}... ")

	#---------------------------------------------------------------------------------------#
	#-										DOWNLOAD									   -#
	#---------------------------------------------------------------------------------------#
  if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(l_IPM_archive_name "doxygen-${a_IPM_version}.windows.bin.zip")
  elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(l_IPM_archive_name "doxygen-${a_IPM_version}.linux.bin.tar.gz")
  else()
    inquire_message(FATAL_ERROR "OS ${CMAKE_SYSTEM_NAME} not yet supported.")
  endif()
	set(l_IPM_doxygen_location "ftp://ftp.stack.nl/pub/users/dimitri/${l_IPM_archive_name}")
	set(l_IPM_doxygen_local_dir ${a_IPM_package_root}/${a_IPM_version})
	set(l_IPM_doxygen_local_archive "${l_IPM_doxygen_local_dir}/download/${l_IPM_archive_name}")

	if(NOT EXISTS "${l_IPM_doxygen_local_archive}")
		inquire_message(INFO "Downloading Doxygen ${a_IPM_version} from ${l_IPM_doxygen_location}.")
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

	inquire_message(INFO "Extracting Doxygen ${a_IPM_version}...")
	file(MAKE_DIRECTORY ${l_IPM_doxygen_local_dir}/install/)
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${l_IPM_doxygen_local_archive} WORKING_DIRECTORY ${l_IPM_doxygen_local_dir}/install/)
	inquire_message(INFO "Extracting Doxygen ${a_IPM_version}... DONE.")

	#---------------------------------------------------------------------------------------#
	#-										GENERATE INCLUDE FILE 									   -#
	#---------------------------------------------------------------------------------------#

  if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(l_IPM_doxygen_executable "${l_IPM_doxygen_local_dir}/install/doxygen.exe")
  elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(l_IPM_archive_name "${l_IPM_doxygen_local_dir}/install/doxygen-${l_IPM_version_dir}/bin/doxygen")
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

	set(${a_IPM_result} ${l_IPM_doxygen_local_dir} PARENT_SCOPE)
endfunction()

function(package_version_need_compilation a_IPM_package_version_root a_IPM_result)
	set(${a_IPM_result} FALSE PARENT_SCOPE)
endfunction()

function(configure_package_version a_IPM_package_version_root)
	IPM_configure_package_version_parse_arguments(l_IPM_configure_package_version ${ARGN})

  set(${l_IPM_configure_package_version_FILES_TO_INCLUDE} "${a_IPM_package_version_root}/include/doxygen.cmake" PARENT_SCOPE)
endfunction()
