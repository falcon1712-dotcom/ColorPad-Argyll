#include <napi/native_api.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string>

static napi_value RunArgyll(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    // читаем строку аргументов
    char cmd[512];
    size_t cmd_len;
    napi_get_value_string_utf8(env, argv[0], cmd, sizeof(cmd), &cmd_len);

    // выполняем системный вызов (Argyll-бинарник лежит в /resources)
    FILE* fp = popen(cmd, "r");
    char buf[1024];
    std::string out = "";
    while (fgets(buf, sizeof(buf), fp) != nullptr) out += buf;
    pclose(fp);

    // возвращаем stdout в JS
    napi_value result;
    napi_create_string_utf8(env, out.c_str(), out.size(), &result);
    return result;
}

EXTERN_C_START
napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc = {"runArgyll", nullptr, RunArgyll, nullptr, nullptr, nullptr, napi_default, nullptr};
    napi_define_properties(env, exports, 1, &desc);
    return exports;
}
EXTERN_C_END