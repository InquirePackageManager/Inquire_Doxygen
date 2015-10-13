set(Doxygen_COMPATIBLE_VERSION_FOUND FALSE)

IPM_get_subdirectories(${IPM_PACKAGE_ROOT} l_IPM_version_dirs)

#try to find a matching version
foreach(l_IPM_version_dir ${l_IPM_version_dirs})
	set(l_IPM_version_compatible FALSE)
  #if the doxygen executable file exists, the installation is valid.
  #NOTE : on linux, the packaging is in an inner folder named bin. On windows, executable are at the root...
	if(EXISTS ${a_IPM_package_root}/${l_IPM_version_dir}/doxygen.exe OR EXISTS ${a_IPM_package_root}/${l_IPM_version_dir}/doxygen-${l_IPM_version_dir}/bin/doxygen)
		if(${l_IPM_version_dir} VERSION_EQUAL ${a_IPM_version})
			set(l_IPM_version_compatible TRUE)
			set(Doxygen_COMPATIBLE_VERSION_FOUND ${a_IPM_package_root}/${l_IPM_version_dir} PARENT_SCOPE)
			break()
		else()
			#we assume that greater versions are backward compatible
			if(${l_IPM_version_dir} VERSION_GREATER ${a_IPM_version} AND NOT ${l_IPM_get_compatible_package_version_root_EXACT})
				set(l_IPM_version_compatible TRUE)
				set(Doxygen_COMPATIBLE_VERSION_FOUND ${a_IPM_package_root}/${l_IPM_version_dir} PARENT_SCOPE)
				break()
			endif()
		endif()
	endif()
endforeach()

if(NOT ${Doxygen_COMPATIBLE_VERSION_FOUND})
  inquire_message(INFO "No compatible version of Boost found.")
endif()
