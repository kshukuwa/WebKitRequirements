set(VERSION 2.13.0)

# Get archive
vcpkg_download_distfile(ARCHIVE
    URLS 
        "https://download.savannah.gnu.org/releases/freetype/freetype-${VERSION}.tar.xz"
        "https://downloads.sourceforge.net/project/freetype/freetype2/${VERSION}/freetype-${VERSION}.tar.xz"
    FILENAME "freetype-${VERSION}.tar.xz"
    SHA512 b93a69a92b99f54c4fc4a276066bc7a87597df132e42ef93f6d973f1425e64bebcc568defa511d39fb04ab4d3a2090a6db1e54cf992a80ff57d658fee28a9110
)

# Patches
set(PATCHES
    ${CMAKE_CURRENT_LIST_DIR}/patches/0001-Adjust-CMake-for-vcpkg.patch
    ${CMAKE_CURRENT_LIST_DIR}/patches/0002-Use-FreeType-DEFLATE-library.patch
)

# Extract archive
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES ${PATCHES}
)

# Run CMake build
set(BUILD_OPTIONS
    # No BZIP support
    -DFT_DISABLE_BZIP2=ON
    -DFT_REQUIRE_BZIP2=OFF
    # No Harfbuzz support
    -DFT_DISABLE_HARFBUZZ=ON
    -DFT_REQUIRE_HARFBUZZ=OFF
)

if (png IN_LIST FEATURES)
    message(STATUS "Enabling libpng")
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_PNG=OFF -DFT_REQUIRE_PNG=ON)
else ()
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_PNG=ON -DFT_REQUIRE_PNG=OFF)
endif ()

if (woff2 IN_LIST FEATURES)
    message(STATUS "Enabling woff2")
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_BROTLI=OFF -DFT_REQUIRE_BROTLI=ON)
else ()
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_BROTLI=ON -DFT_REQUIRE_BROTLI=OFF)
endif ()

if (zlib IN_LIST FEATURES)
    message(STATUS "Enabling system zlib")
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_ZLIB=OFF -DFT_REQUIRE_ZLIB=ON)
else ()
    list(APPEND BUILD_OPTIONS -DFT_DISABLE_ZLIB=ON -DFT_REQUIRE_ZLIB=OFF)
endif ()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${BUILD_OPTIONS}
        -DDISABLE_FORCE_DEBUG_POSTFIX=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Prepare distribution
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype RENAME copyright)
file(INSTALL 
    ${SOURCE_PATH}/docs/FTL.txt
    ${SOURCE_PATH}/docs/GPLv2.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/freetype
)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/freetype/version ${VERSION})
