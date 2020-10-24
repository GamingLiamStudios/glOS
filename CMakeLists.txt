cmake_minimum_required(VERSION 3.15)
project(glOS LANGUAGES ASM_NASM C)

# Make sure everything is compiled into the same dir
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${PROJECT_NAME})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${PROJECT_NAME})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -m64 -ffreestanding -mno-red-zone")
set(CMAKE_EXE_LINKER_FLAGS "-Ttext 0x7c00 -nostdlib -nodefaultlibs")

include_directories(source)

set(SOURCE_FILES
    # Kernel
    source/kernel/kernel.asm
    source/kernel/kernel.c
)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})
set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})

add_custom_command(
    TARGET ${PROJECT_NAME} PRE_BUILD
    COMMAND nasm source/bootloader/bootloader.asm -f bin -o $<TARGET_FILE_DIR:${PROJECT_NAME}>/boot.bin
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

# TODO: Check if this is cross-platform
if(WIN32)   
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND objcopy -O binary ${PROJECT_NAME}.exe ${PROJECT_NAME}.bin
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND dd if=${PROJECT_NAME}.bin of=boot.bin status=none conv=notrunc oflag=append
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND "C:/Program Files/qemu/qemu-system-x86_64.exe" boot.bin
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
elseif(UNIX)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND objcopy -O binary ${PROJECT_NAME} ${PROJECT_NAME}.bin
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND dd if=${PROJECT_NAME}.bin of=boot.bin status=none conv=notrunc oflag=append
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND qemu boot.bin
        WORKING_DIRECTORY $<TARGET_FILE_DIR:${PROJECT_NAME}>)
endif()
    
add_custom_command(
    TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND rm -f $<TARGET_FILE_DIR:${PROJECT_NAME}>/*
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})