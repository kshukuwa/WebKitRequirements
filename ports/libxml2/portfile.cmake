include(vcpkg_common_functions)

set(LIBXML2_VERSION 2.9.9)

# Get archive
vcpkg_download_distfile(ARCHIVE
    URLS "http://xmlsoft.org/sources/libxml2-${LIBXML2_VERSION}.tar.gz"
    FILENAME "libxml2-${LIBXML2_VERSION}.tar.gz"
    SHA512 cb7784ba4e72e942614e12e4f83f4ceb275f3d738b30e3b5c1f25edf8e9fa6789e854685974eed95b362049dbf6c8e7357e0327d64c681ed390534ac154e6810
)

# Extract archive
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBXML2_VERSION}
)

# Add CMake sources
file(COPY ${CMAKE_CURRENT_LIST_DIR}/build/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/build/include/libxml/xmlversion.h.cmake.in DESTINATION ${SOURCE_PATH}/include/libxml)

# Run CMake build
set(BUILD_OPTIONS
    # Threading
    -DLIBXML_THREAD_SAFETY=no
    -DWITH_THREAD_ALLOC=OFF

    # Options
    -DWITH_C14N=OFF
    -DWITH_CATALOG=OFF
    -DWITH_DEBUG=OFF
    -DWITH_DOCB=OFF
    -DWITH_FTP=OFF
    -DWITH_FTP=OFF
    -DWITH_HTTP=OFF
    -DWITH_ICONV=OFF
    -DWITH_ICU=ON
    -DWITH_ISO8859X=ON
    -DWITH_LEGACY=OFF
    -DWITH_MEM_DEBUG=OFF
    -DWITH_MODULES=OFF
    -DWITH_OUTPUT=ON
    -DWITH_PATTERN=OFF
    -DWITH_PUSH=ON
    -DWITH_PYTHON=OFF
    -DWITH_READER=OFF
    -DWITH_REGEXPS=ON
    -DWITH_RUN_DEBUG=OFF
    -DWITH_SAX1=ON
    -DWITH_SCHEMAS=OFF
    -DWITH_SCHEMATRON=OFF
    -DWITH_VALID=OFF
    -DWITH_WALKER=ON
    -DWITH_WRITER=OFF
    -DWITH_XINCLUDE=OFF
    -DWITH_XPTR=OFF
    -DWITH_ZLIB=OFF
)

# Windows builds have a config.h in the repository
if (NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME MATCHES "^Windows")
    list(APPEND BUILD_OPTIONS -DLIBXML2_CONFIG_INCLUDE_DIR=win32/VC10)
else ()
    if (NOT DEFINED LIBXML2_CONFIG_INCLUDE_DIR)
        message(FATAL_ERROR "A config.h file is required to build libxml2. Generate and set LIBXML2_CONFIG_INCLUDE_DIR in the triplet")
    endif ()

    file(COPY ${CMAKE_CURRENT_LIST_DIR}/build/${LIBXML2_CONFIG_INCLUDE_DIR} DESTINATION ${SOURCE_PATH})
    list(APPEND BUILD_OPTIONS -DLIBXML2_CONFIG_INCLUDE_DIR=${LIBXML2_CONFIG_INCLUDE_DIR})
endif ()

# libxslt requires certain features to be turned on
if (xslt IN_LIST FEATURES)
    list(APPEND BUILD_OPTIONS
        -DWITH_HTML=ON
        -DWITH_TREE=ON
        -DWITH_XPATH=ON
    )
else ()
    list(APPEND BUILD_OPTIONS
        -DWITH_HTML=OFF
        -DWITH_TREE=OFF
        -DWITH_XPATH=OFF
    )
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${BUILD_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Prepare distribution
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxml2 RENAME copyright)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libxml2/version ${LIBXML2_VERSION})
