# Replaces plasma-workspace's top-level CMakeLists so only xembed-sni-proxy builds.
cmake_minimum_required(VERSION 3.16)
project(xembedsniproxy VERSION ${WORKSPACE_VERSION})

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMQtDeclareLoggingCategory)
include(ECMConfiguredInstall)
include(FeatureSummary)

find_package(Qt6 REQUIRED COMPONENTS Core DBus Gui)
find_package(KF6 REQUIRED COMPONENTS CoreAddons Crash DBusAddons WindowSystem)
find_package(X11 REQUIRED)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

configure_file(config-workspace.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-workspace.h)
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_subdirectory(xembed-sni-proxy)
