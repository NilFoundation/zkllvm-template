cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(crypto3-template)

add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/libs/crypto3")

#Example directories
add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/src/bls")
add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/src/bls_weighted_threshold_sig")
