#!/usr/bin/env python
import subprocess
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.

# 解决这个警告warning C4819: 该文件包含不能在当前代码页(936)中表示的字符。请将该文件保存为 Unicode 格式以防止数据丢失
env.Append(CPPFLAGS=["/source-charset:utf-8"])

env.Append(CPPPATH=["src/"])
env.Append(LIBPATH=["src/librealsense2/lib"])
# env.Append(LIBPATH=[
#            'D:\\Godot\\4.0\\gdextension_realsense\\src\\librealsense2\\lib'])
env.Append(LIBS=["realsense2"])

""" # Kinect 路径
env.Append(
    CPPPATH=["C:/Program Files/Microsoft SDKs/Kinect/v2.0_1409/inc"])

# env_gkinect.Append(LIBPATH=["C:/Program Files/Microsoft SDKs/Kinect/v2.0_1409/Lib/x64"])

env.Append(LINKFLAGS=[
           "C:/Program Files/Microsoft SDKs/Kinect/v2.0_1409/Lib/x64/Kinect20.lib"]) """

sources = Glob("src/*.cpp")


if env["platform"] == "macos":
    library = env.SharedLibrary(
        "app/bin/libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    env["LINKFLAGS"] = ["-static-libgcc -static-libstdc++ -static -pthread"]
    library = env.SharedLibrary(
        # 动态库生成的路径及其文件名
        "app/bin/libgdexample{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,

    )

Default(library)
