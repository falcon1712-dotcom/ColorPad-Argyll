#include <napi/native_api.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string>
#include <fstream>

// Путь к бинарникам на устройстве
#define ARGYLL_PATH "/data/app/argyll/"

// Копируем бинарники из ресурсов в рабочую папку (выполняется один раз)
static bool extractBinaries(napi_env env) {
    static bool extracted = false;
    if (extracted) return true;

    // Создаём папку
    mkdir(ARGYLL_PATH, 0755);
    
    // Копируем каждый файл (упрощённо, в MVP кладём вручную)
    extracted = true;
    return true;
}

static napi_value RunArgyll(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    char cmd[512];
    size_t cmd_len;
    napi_get_value_string_utf8(env, argv[0], cmd, sizeof(cmd), &cmd_len);

    // Выполняем команду с полным путём
    char full_cmd[1024];
    snprintf(full_cmd, sizeof(full_cmd), "cd %s && %s", ARGYLL_PATH, cmd);
    
    FILE* fp = popen(full_cmd, "r");
    char buf[1024];
    std::string out = "";
    while (fgets(buf, sizeof(buf), fp) != nullptr) out += buf;
    pclose(fp);

    napi_value result;
    napi_create_string_utf8(env, out.c_str(), out.size(), &result);
    return result;
}

EXTERN_C_START
napi_value Init(napi_env env, napi_value exports) {
    extractBinaries(env);
    napi_property_descriptor desc = {"runArgyll", nullptr, RunArgyll, nullptr, nullptr, nullptr, napi_default, nullptr};
    napi_define_properties(env, exports, 1, &desc);
    return exports;
}
EXTERN_C_END