set(CRYPTO3_DEPENDENCIES
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
)

add_library(template_lib INTERFACE)

target_include_directories(template_lib 
    INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>" "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")
target_link_libraries(template_lib INTERFACE ${CRYPTO3_DEPENDENCIES})


function(add_example example_target)
    set(prefix ARG)
    set(noValues "")
    set(singleValues INPUT)
    set(multiValues SOURCES)
    cmake_parse_arguments(${prefix}
                        "${noValues}"
                        "${singleValues}"
                        "${multiValues}"
                        ${ARGN})
    add_circuit(${example_target}
                SOURCES ${ARG_SOURCES}

                LINK_LIBRARIES ${CRYPTO3_DEPENDENCIES} ${Boost_LIBRARIES} template_lib)
endfunction()

add_example(template SOURCES main.cpp INPUT main.inp)

