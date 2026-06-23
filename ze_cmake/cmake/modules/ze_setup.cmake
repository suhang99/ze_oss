include(ze_options)

# common flags
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  # GCC (e.g. Linux/WSL): original flags, including -Werror and GCC-only options.
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -fPIC -D_REENTRANT -Wno-maybe-uninitialized -Wno-unused-variable -Wno-unused-but-set-variable -Wno-unknown-pragmas -Wno-error=deprecated-declarations")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O3 -fsee -fomit-frame-pointer -fno-signed-zeros -fno-math-errno -funroll-loops -ffast-math -fno-finite-math-only")
else()
  # Clang (e.g. macOS): -Wno-maybe-uninitialized and -fsee are GCC-only, and
  # clang's stricter warning set would break -Werror. Keep warnings without -Werror.
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -fPIC -D_REENTRANT -Wno-unused-variable -Wno-unknown-pragmas -Wno-deprecated-declarations")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O3 -fomit-frame-pointer -fno-signed-zeros -fno-math-errno -funroll-loops -ffast-math -fno-finite-math-only")
endif()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
endif()


find_package(Threads)
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)
if (CMAKE_USE_PTHREADS_INIT)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif ()

# arm
if(DEFINED ENV{ARM_ARCHITECTURE})
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfpu=neon -march=armv7-a")
  add_definitions(-DHAVE_FAST_NEON)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|amd64|i386|i686")
  # x86 SIMD flags are invalid on Apple Silicon / arm64 (NEON is baseline there)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mmmx -msse -msse -msse2 -msse3 -mssse3")
endif()

# c++11
if (CMAKE_VERSION VERSION_LESS "3.1" OR Boost_VERSION VERSION_LESS "1.56")
  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set (CMAKE_CXX_FLAGS "--std=gnu++11 ${CMAKE_CXX_FLAGS}")
  elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++")
  else ()
    message(SEND_ERROR "Unknown or unsupported system.")
  endif ()
else ()
  set (CMAKE_CXX_STANDARD 11)
endif ()

# RT library (librt does not exist on macOS; clock_gettime etc. live in libc)
if(NOT APPLE)
  find_library(RT_LIBRARY NAMES rt librt)
  list(APPEND ZE_LIBRARIES ${RT_LIBRARY})
endif()

# forward pure cmake dependencies if not added by <depend> in the package xml
# but should be forwarded from/to the packages
list(APPEND catkin_LIBRARIES ${ZE_LIBRARIES})
