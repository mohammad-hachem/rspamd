# Ported from Clickhouse: https://github.com/ClickHouse/ClickHouse/blob/master/cmake/sanitize.cmake

option (SANITIZE "Enable sanitizer: address, memory, undefined" "")
set (SAN_FLAGS "${SAN_FLAGS} -g -fno-omit-frame-pointer -DSANITIZER")
# O1 is normally set by clang, and -Og by gcc
if (COMPILER_GCC)
    set (SAN_FLAGS "${SAN_FLAGS} -Og")
else ()
    set (SAN_FLAGS "${SAN_FLAGS} -O1")
endif ()
if (SANITIZE)
    if (SANITIZE STREQUAL "address")
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SAN_FLAGS} -fsanitize=address -fsanitize-address-use-after-scope")
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SAN_FLAGS} -fsanitize=address -fsanitize-address-use-after-scope")
        if (COMPILER_GCC)
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address -fsanitize-address-use-after-scope")
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libasan")
        endif ()

    elseif (SANITIZE STREQUAL "memory")
        set (MSAN_FLAGS "-fsanitize=memory -fsanitize-memory-track-origins -fno-optimize-sibling-calls")

        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SAN_FLAGS} ${MSAN_FLAGS}")
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SAN_FLAGS} ${MSAN_FLAGS}")

        if (COMPILER_GCC)
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=memory")
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libmsan")
        endif ()

    elseif (SANITIZE STREQUAL "undefined")
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${SAN_FLAGS} -fsanitize=undefined -fno-sanitize-recover=all")
        set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${SAN_FLAGS} -fsanitize=undefined -fno-sanitize-recover=all")
        if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=undefined")
        endif()
        if (CMAKE_C_COMPILER_ID STREQUAL "GNU")
            set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libubsan")
        endif ()

        message (FATAL_ERROR "Unknown sanitizer type: ${SANITIZE}")
    endif ()
    message (STATUS "Add sanitizer: ${SANITIZE}")
endif()