class Tdlib < Formula
  desc "Cross-platform library for building Telegram clients"
  homepage "https://core.telegram.org/tdlib"
  url "https://github.com/tdlib/td/archive/v1.3.0.tar.gz"
  sha256 "2953fe75027ac531248b359123aa4812666377ac874c1db506fa74176f2d2338"
  head "https://github.com/tdlib/td.git"

  depends_on "cmake" => :build
  depends_on "openssl"
  depends_on "gperf"
  depends_on "readline"

  def install
    mkdir "build" do
      system "cmake", '-DCMAKE_BUILD_TYPE=Release', '-DOPENSSL_ROOT_DIR=/usr/local/Cellar/openssl/1.0.2p', '..'
      system "cmake", ".", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"tdjson_example.cpp").write <<~EOS
      #include "td/telegram/td_json_client.h"

      #include <iostream>

      int main() {
        void* client = td_json_client_create();
        std::cout << "Client created: " << client;
        return 0;
      }
    EOS

    (testpath/"CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.1 FATAL_ERROR)

      project(TdExample VERSION 1.0 LANGUAGES CXX)

      find_package(Td 1.3.0 REQUIRED)

      add_executable(tdjson_example tdjson_example.cpp)
      target_link_libraries(tdjson_example PRIVATE Td::TdJson)
      set_property(TARGET tdjson_example PROPERTY CXX_STANDARD 11)
    EOS

    system "cmake", "."
    system "make"
    assert_match "Client created", shell_output("./tdjson_example", 0)
  end
end
