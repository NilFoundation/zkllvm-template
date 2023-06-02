#---------------------------------------------------------------------------#
# Copyright (c) 2018-2023 Mikhail Komarov <nemo@nil.foundation>
#
# Distributed under the Boost Software License, Version 1.0
# See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt
#---------------------------------------------------------------------------#

cm_project(template WORKSPACE_NAME ${CMAKE_WORKSPACE_NAME} LANGUAGES C CXX)

list(APPEND ${CURRENT_PROJECT_NAME}_PUBLIC_HEADERS)

list(APPEND ${CURRENT_PROJECT_NAME}_UNGROUPED_SOURCES)

list(APPEND ${CURRENT_PROJECT_NAME}_HEADERS
     ${${CURRENT_PROJECT_NAME}_PUBLIC_HEADERS})

list(APPEND ${CURRENT_PROJECT_NAME}_SOURCES
     ${${CURRENT_PROJECT_NAME}_UNGROUPED_SOURCES})

cm_setup_version(VERSION 0.1.0 PREFIX ${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME})

add_library(${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME} INTERFACE)

set_target_properties(${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME} PROPERTIES
                      EXPORT_NAME ${CURRENT_PROJECT_NAME})

target_link_libraries(${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME} INTERFACE
                      crypto3::algebra
                      crypto3::block
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

target_include_directories(${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME} INTERFACE
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
                           $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>

                           ${Boost_INCLUDE_DIRS})

cm_deploy(TARGETS ${CMAKE_WORKSPACE_NAME}_${CURRENT_PROJECT_NAME}
          INCLUDE include
          NAMESPACE ${CMAKE_WORKSPACE_NAME}::)

if(BUILD_TESTS)
    add_subdirectory(test)
endif()