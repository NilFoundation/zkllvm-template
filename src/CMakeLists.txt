include(CMConfig)
include(CMSetupVersion)
include(CMDeploy)

cm_find_package(CM)

cm_project(template WORKSPACE_NAME ${CMAKE_WORKSPACE_NAME} LANGUAGES ASM C CXX)

cm_setup_version(VERSION 0.1.0 PREFIX ${CMAKE_WORKSPACE_NAME}_${CMAKE_PROJECT_NAME})

# get header files; only needed by CMake generators,
# expr.g., for creating proper Xcode projects
list(APPEND ${CMAKE_PROJECT_NAME}_HEADERS)

# list cpp files excluding platform-dependent files
list(APPEND ${CMAKE_PROJECT_NAME}_SOURCES main.cpp)

add_circuit(${CMAKE_WORKSPACE_NAME}_${CMAKE_PROJECT_NAME}
            SOURCES ${${CMAKE_PROJECT_NAME}_HEADERS} ${${CMAKE_PROJECT_NAME}_SOURCES}

            INCLUDE_DIRECTORIES
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>

            LINK_LIBRARIES
            crypto3::algebra
            crypto3::block
            crypto3::blueprint
            crypto3::codec
            crypto3::containers
            crypto3::hash
            crypto3::kdf
            crypto3::mac
            marshalling::core
            marshalling::crypto3_algebra
            marshalling::crypto3_multiprecision
            marshalling::crypto3_zk
            crypto3::math
            crypto3::modes
            crypto3::multiprecision
            crypto3::passhash
            crypto3::pbkdf
            crypto3::threshold
            crypto3::pkpad
            crypto3::pubkey
            crypto3::random
            crypto3::stream
            crypto3::vdf
            crypto3::zk

            ${Boost_LIBRARIES})

set_target_properties(${CMAKE_WORKSPACE_NAME}_${CMAKE_PROJECT_NAME} PROPERTIES
                      LINKER_LANGUAGE CXX
                      EXPORT_NAME ${CMAKE_PROJECT_NAME}
                      CXX_STANDARD 17
                      CXX_STANDARD_REQUIRED TRUE)