### Wisecracker: A cryptanalysis framework
### Copyright (c) 2011-2012, Vikas Naresh Kumar, Selective Intellect LLC
###    
###	This program is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see <http://www.gnu.org/licenses/>.
#########################################################################
### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas Kumar
### DATE: 21st Dec 2011
#########################################################################
if (NOT OPENCL_ROOT)
	set(OPENCL_ROOT_ENV $ENV{OPENCL_ROOT})
	if (OPENCL_ROOT_ENV)
		file(TO_CMAKE_PATH ${OPENCL_ROOT_ENV} OPENCL_ROOT)
		message(STATUS "Using OPENCL from ${OPENCL_ROOT}")
	endif (OPENCL_ROOT_ENV)
else (NOT OPENCL_ROOT)
	set(OPENCL_ROOT_SAVE ${OPENCL_ROOT})
	file(TO_CMAKE_PATH ${OPENCL_ROOT_SAVE} OPENCL_ROOT)
endif (NOT OPENCL_ROOT)

if (NOT OPENCL_ROOT)
	message(FATAL_ERROR "Please set the CMake variable or environment "
		"variable OPENCL_ROOT to point to the OpenCL installation")
endif (NOT OPENCL_ROOT)
if (OPENCL_ROOT MATCHES "NVIDIA" OR OPENCL_ROOT MATCHES "nvidia")
	set(USE_NVIDIA 1)
	message(STATUS "Possibly using NVIDIA's OpenCL")
else (OPENCL_ROOT MATCHES "NVIDIA" OR OPENCL_ROOT MATCHES "nvidia")
	set(USE_NVIDIA 0)
	message(STATUS "Possibly using AMD's OpenCL")
endif (OPENCL_ROOT MATCHES "NVIDIA" OR OPENCL_ROOT MATCHES "nvidia")
set(OPENCL_INCLUDES
	${OPENCL_ROOT}/include
	${OPENCL_ROOT}/inc
	${OPENCL_ROOT}/common/include
	${OPENCL_ROOT}/common/inc
	)
# AMD's Windows install uses the ARCH/lib and NVIDIA uses lib/Win32
# NVIDIA's uses lib/x64 for x64 architecture as well
set(OPENCL_LDFLAGS ${OPENCL_ROOT}/lib ${OPENCL_ROOT}/${ARCH}/lib
	${OPENCL_ROOT}/${WINARCH}/lib ${OPENCL_ROOT}/lib/${WINARCH}
	${OPENCL_ROOT}/lib/${ARCH} ${OPENCL_ROOT}/${WINARCH2}/lib
	${OPENCL_ROOT}/lib/${WINARCH2})
set(OPENCL_LIBS OpenCL)
set(OPENCL_FILENAME OpenCL.dll)
if (USE_NVIDIA)
	file(TO_CMAKE_PATH $ENV{SYSTEMROOT} SYSTEMROOT)
	if (ARCH STREQUAL "x86")
		if (EXISTS ${SYSTEMROOT}/SysWOW64/${OPENCL_FILENAME})
			set(OPENCL_LIB_FILE ${SYSTEMROOT}/SysWOW64/${OPENCL_FILENAME})
		else (EXISTS ${SYSTEMROOT}/SysWOW64/${OPENCL_FILENAME})
			if (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
				set(OPENCL_LIB_FILE ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
			else (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
				message(WARNING "Cannot find ${OPENCL_LIB_FILE} in"
					" ${SYSTEMROOT}/System32 or ${SYSTEMROOT}/SysWOW64")
			endif (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
		endif (EXISTS ${SYSTEMROOT}/SysWOW64/${OPENCL_FILENAME})
	else (ARCH STREQUAL "x86")
		if (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
			set(OPENCL_LIB_FILE ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
		else (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
			message(WARNING "Cannot find ${OPENCL_LIB_FILE} in"
				" ${SYSTEMROOT}/System32")
		endif (EXISTS ${SYSTEMROOT}/System32/${OPENCL_FILENAME})
	endif (ARCH STREQUAL "x86")
else (USE_NVIDIA)
	set(OPENCL_LIB_FILE ${OPENCL_ROOT}/bin/${ARCH}/${OPENCL_FILENAME})
endif (USE_NVIDIA)
if (EXISTS ${OPENCL_LIB_FILE})
	file(COPY ${OPENCL_LIB_FILE} DESTINATION ${WC_SRCBIN_DIR})
	install(PROGRAMS ${OPENCL_LIB_FILE} DESTINATION bin)
else (EXISTS ${OPENCL_LIB_FILE})
	set(OPENCL_LIB_FILE2 ${OPENCL_ROOT}/bin/${OPENCL_FILENAME})
	if (EXISTS ${OPENCL_LIB_FILE2})
		file(COPY ${OPENCL_LIB_FILE2} DESTINATION ${WC_SRCBIN_DIR})
		install(PROGRAMS ${OPENCL_LIB_FILE2} DESTINATION bin)
		set(OPENCL_LIB_FILE ${OPENCL_LIB_FILE2})
	else (EXISTS ${OPENCL_LIB_FILE2})
		message(WARNING "${OPENCL_FILENAME} not found")
		set(OPENCL_LIB_FILE "" CACHE "" INTERNAL FORCE)
	endif (EXISTS ${OPENCL_LIB_FILE2})
endif (EXISTS ${OPENCL_LIB_FILE})
message(STATUS "Using ${OPENCL_LIB_FILE}")

set(CMAKE_REQUIRED_INCLUDES_SAVE ${CMAKE_REQUIRED_INCLUDES})
set(CMAKE_REQUIRED_INCLUDES ${OPENCL_INCLUDES})
check_include_file("CL/opencl.h" WC_OPENCL_H)
set(CMAKE_REQUIRED_INCLUDES ${CMAKE_REQUIRED_INCLUDES_SAVE})

if (WC_OPENCL_H)
	include_directories(${OPENCL_INCLUDES})
	link_directories(${OPENCL_LDFLAGS})
else (WC_OPENCL_H)
	message(FATAL_ERROR "OpenCL is not found. Please set OPENCL_ROOT variable "
		"to point correctly to the OpenCL installation folder.")
endif (WC_OPENCL_H)
