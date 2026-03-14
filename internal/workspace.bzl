"""Shared Bun workspace metadata and launcher helpers."""

BunWorkspaceInfo = provider(
    doc = "Workspace/runtime metadata shared by Bun rules and adapters.",
    fields = {
        "install_metadata_file": "Optional install metadata file from bun_install.",
        "metadata_file": "Rule-local metadata file describing the staged workspace inputs.",
        "node_modules_files": "Depset of node_modules files from bun_install.",
        "package_dir_hint": "Package-relative directory when known at analysis time.",
        "package_json": "Package manifest file when explicitly provided.",
        "primary_file": "Primary source file used to resolve the runtime package context.",
        "runtime_files": "Depset of runtime files required to stage the workspace.",
    },
)

_WORKSPACE_SETUP_TEMPLATE = """#!/usr/bin/env bash
set -euo pipefail

runfiles_dir="${RUNFILES_DIR:-$0.runfiles}"
workspace_root="${runfiles_dir}/_main"
workspace_root="$(cd "${workspace_root}" && pwd -P)"
bun_bin="${runfiles_dir}/_main/__BUN_SHORT_PATH__"
primary_source=""
if [[ -n "__PRIMARY_SOURCE_SHORT_PATH__" ]]; then
    primary_source="${runfiles_dir}/_main/__PRIMARY_SOURCE_SHORT_PATH__"
fi
package_json=""
if [[ -n "__PACKAGE_JSON_SHORT_PATH__" ]]; then
    package_json="${runfiles_dir}/_main/__PACKAGE_JSON_SHORT_PATH__"
fi
package_rel_dir_hint="__PACKAGE_DIR_HINT__"
working_dir_mode="__WORKING_DIR_MODE__"

normalize_rel_dir() {
    local value="$1"
    if [[ -z "${value}" || "${value}" == "." ]]; then
        echo "."
    else
        echo "${value#./}"
    fi
}

dirname_rel_dir() {
    local value
    value="$(normalize_rel_dir "$1")"
    if [[ "${value}" == "." || "${value}" != */* ]]; then
        echo "."
        return 0
    fi
    echo "${value%/*}"
}

first_path_component() {
    local value
    value="$(normalize_rel_dir "$1")"
    if [[ "${value}" == "." ]]; then
        echo ""
        return 0
    fi
    echo "${value%%/*}"
}

rel_dir_from_abs_path() {
    local absolute_path="$1"
    if [[ "${absolute_path}" == "${workspace_root}" ]]; then
        echo "."
        return 0
    fi
    echo "${absolute_path#"${workspace_root}/"}"
}

find_package_rel_dir_for_path() {
    local path="$1"
    local dir="$1"
    if [[ -f "${dir}" ]]; then
        dir="$(dirname "${dir}")"
    fi

    while [[ "${dir}" == "${workspace_root}"* ]]; do
        if [[ -f "${dir}/package.json" ]]; then
            rel_dir_from_abs_path "${dir}"
            return 0
        fi
        if [[ "${dir}" == "${workspace_root}" ]]; then
            break
        fi
        dir="$(dirname "${dir}")"
    done

    rel_dir_from_abs_path "$(dirname "${path}")"
}

find_working_rel_dir_for_path() {
    local path="$1"
    local dir="$1"
    if [[ -f "${dir}" ]]; then
        dir="$(dirname "${dir}")"
    fi

    while [[ "${dir}" == "${workspace_root}"* ]]; do
        if [[ -f "${dir}/.env" || -f "${dir}/package.json" ]]; then
            rel_dir_from_abs_path "${dir}"
            return 0
        fi
        if [[ "${dir}" == "${workspace_root}" ]]; then
            break
        fi
        dir="$(dirname "${dir}")"
    done

    rel_dir_from_abs_path "$(dirname "${path}")"
}

select_primary_node_modules() {
    local selected=""
    local fallback=""
    while IFS= read -r node_modules_dir; do
        if [[ -z "${fallback}" ]]; then
            fallback="${node_modules_dir}"
        fi

        if [[ ! -d "${node_modules_dir}/.bun" ]]; then
            continue
        fi

        if [[ "${node_modules_dir}" != *"/runfiles/_main/"* ]]; then
            selected="${node_modules_dir}"
            break
        fi

        if [[ -z "${selected}" ]]; then
            selected="${node_modules_dir}"
        fi
    done < <(find -L "${runfiles_dir}" -type d -name node_modules 2>/dev/null | sort)

    if [[ -n "${selected}" ]]; then
        echo "${selected}"
    else
        echo "${fallback}"
    fi
}

link_top_level_entries() {
    local source_root="$1"
    local destination_root="$2"
    local skipped_entry="$3"
    local entry=""
    local entry_name=""

    shopt -s dotglob nullglob
    for entry in "${source_root}"/* "${source_root}"/.[!.]* "${source_root}"/..?*; do
        entry_name="$(basename "${entry}")"
        if [[ "${entry_name}" == "." || "${entry_name}" == ".." ]]; then
            continue
        fi
        if [[ -n "${skipped_entry}" && "${entry_name}" == "${skipped_entry}" ]]; then
            continue
        fi
        ln -s "${entry}" "${destination_root}/${entry_name}"
    done
    shopt -u dotglob nullglob
}

materialize_package_path() {
    local source_root="$1"
    local destination_root="$2"
    local package_rel_dir
    package_rel_dir="$(normalize_rel_dir "$3")"

    if [[ "${package_rel_dir}" == "." ]]; then
        return 0
    fi

    local source_cursor="${source_root}"
    local destination_cursor="${destination_root}"
    local parts=()
    local current="${package_rel_dir}"

    while [[ -n "${current}" ]]; do
        if [[ "${current}" == */* ]]; then
            parts+=("${current%%/*}")
            current="${current#*/}"
        else
            parts+=("${current}")
            break
        fi
    done

    local index=0
    while [[ ${index} -lt $((${#parts[@]} - 1)) ]]; do
        local part="${parts[${index}]}"
        local next_part="${parts[$((index + 1))]}"
        source_cursor="${source_cursor}/${part}"
        destination_cursor="${destination_cursor}/${part}"
        mkdir -p "${destination_cursor}"

        local sibling=""
        local sibling_name=""
        shopt -s dotglob nullglob
        for sibling in "${source_cursor}"/* "${source_cursor}"/.[!.]* "${source_cursor}"/..?*; do
            sibling_name="$(basename "${sibling}")"
            if [[ "${sibling_name}" == "." || "${sibling_name}" == ".." || "${sibling_name}" == "${next_part}" ]]; then
                continue
            fi
            if [[ ! -e "${destination_cursor}/${sibling_name}" ]]; then
                ln -s "${sibling}" "${destination_cursor}/${sibling_name}"
            fi
        done
        shopt -u dotglob nullglob
        index=$((index + 1))
    done

    mkdir -p "${destination_root}/${package_rel_dir}"
}

materialize_directory_entries() {
    local source_root="$1"
    local destination_root="$2"
    local entry=""
    local entry_name=""

    mkdir -p "${destination_root}"
    shopt -s dotglob nullglob
    for entry in "${source_root}"/* "${source_root}"/.[!.]* "${source_root}"/..?*; do
        entry_name="$(basename "${entry}")"
        if [[ "${entry_name}" == "." || "${entry_name}" == ".." ]]; then
            continue
        fi
        rm -rf "${destination_root}/${entry_name}"
        ln -s "${entry}" "${destination_root}/${entry_name}"
    done
    shopt -u dotglob nullglob
}

stage_workspace_view() {
    local source_root="$1"
    local destination_root="$2"
    local package_rel_dir
    package_rel_dir="$(normalize_rel_dir "$3")"
    local skipped_entry
    skipped_entry="$(first_path_component "${package_rel_dir}")"

    link_top_level_entries "${source_root}" "${destination_root}" "${skipped_entry}"

    if [[ "${package_rel_dir}" == "." ]]; then
        return 0
    fi

    materialize_package_path "${source_root}" "${destination_root}" "${package_rel_dir}"
    materialize_directory_entries "${source_root}/${package_rel_dir}" "${destination_root}/${package_rel_dir}"
}

build_workspace_package_map() {
    local root="$1"
    local out="$2"

    python3 - "${root}" >"${out}" <<'PY'
import json
import os
import sys

root = os.path.abspath(sys.argv[1])

for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [name for name in dirnames if name != "node_modules"]
    if "package.json" not in filenames:
        continue

    manifest_path = os.path.join(dirpath, "package.json")
    try:
        with open(manifest_path, "r", encoding="utf-8") as manifest_file:
            package_name = json.load(manifest_file).get("name")
    except Exception:
        continue

    if not isinstance(package_name, str):
        continue

    rel_dir = os.path.relpath(dirpath, root)
    if rel_dir == ".":
        rel_dir = "."
    print(f"{package_name}\t{rel_dir}")
PY
}

workspace_package_rel_dir_for_source() {
    local source="$1"
    local manifest_path="${source}/package.json"
    local package_name=""

    if [[ ! -f "${manifest_path}" ]]; then
        return 1
    fi

    package_name="$(python3 - "${manifest_path}" <<'PY'
import json
import sys

try:
    with open(sys.argv[1], "r", encoding="utf-8") as manifest_file:
        package_name = json.load(manifest_file).get("name", "")
except Exception:
    package_name = ""

if isinstance(package_name, str):
    print(package_name)
PY
)"

    if [[ -z "${package_name}" ]]; then
        return 1
    fi

    awk -F '\t' -v name="${package_name}" '$1 == name { print $2; exit }' "${workspace_package_map}"
}

link_node_modules_entry() {
    local source="$1"
    local destination="$2"
    local workspace_rel_dir=""

    rm -rf "${destination}"
    workspace_rel_dir="$(workspace_package_rel_dir_for_source "${source}" || true)"
    if [[ -n "${workspace_rel_dir}" ]]; then
        ln -s "${runtime_workspace}/${workspace_rel_dir}" "${destination}"
        return 0
    fi

    if [[ -L "${source}" ]]; then
        ln -s "$(readlink "${source}")" "${destination}"
    else
        ln -s "${source}" "${destination}"
    fi
}

mirror_node_modules_dir() {
    local source_dir="$1"
    local destination_dir="$2"
    local entry=""
    local entry_name=""
    local scoped_entry=""
    local scoped_name=""

    rm -rf "${destination_dir}"
    mkdir -p "${destination_dir}"

    shopt -s dotglob nullglob
    for entry in "${source_dir}"/* "${source_dir}"/.[!.]* "${source_dir}"/..?*; do
        entry_name="$(basename "${entry}")"
        if [[ "${entry_name}" == "." || "${entry_name}" == ".." || "${entry_name}" == ".rules_bun" ]]; then
            continue
        fi

        if [[ -d "${entry}" && ! -L "${entry}" && "${entry_name}" == @* ]]; then
            mkdir -p "${destination_dir}/${entry_name}"
            for scoped_entry in "${entry}"/* "${entry}"/.[!.]* "${entry}"/..?*; do
                scoped_name="$(basename "${scoped_entry}")"
                if [[ "${scoped_name}" == "." || "${scoped_name}" == ".." ]]; then
                    continue
                fi
                link_node_modules_entry "${scoped_entry}" "${destination_dir}/${entry_name}/${scoped_name}"
            done
            continue
        fi

        link_node_modules_entry "${entry}" "${destination_dir}/${entry_name}"
    done
    shopt -u dotglob nullglob
}

find_install_repo_node_modules() {
    local repo_root="$1"
    local package_rel_dir
    package_rel_dir="$(normalize_rel_dir "$2")"

    if [[ "${package_rel_dir}" != "." ]]; then
        local candidate="${package_rel_dir}"
        while true; do
            if [[ -d "${repo_root}/${candidate}/node_modules" ]]; then
                echo "${repo_root}/${candidate}/node_modules"
                return 0
            fi

            if [[ "${candidate}" != */* ]]; then
                break
            fi
            candidate="${candidate%/*}"
        done
    fi

    if [[ -d "${repo_root}/node_modules" ]]; then
        echo "${repo_root}/node_modules"
        return 0
    fi

    return 1
}

mirror_install_repo_workspace_node_modules() {
    local repo_root="$1"
    local destination_root="$2"

    while IFS= read -r install_node_modules; do
        local rel_path="${install_node_modules#${repo_root}/}"
        local destination="${destination_root}/${rel_path}"

        mkdir -p "$(dirname "${destination}")"
        mirror_node_modules_dir "${install_node_modules}" "${destination}"
    done < <(find "${repo_root}" \
        -path "${repo_root}/node_modules" -prune -o \
        -type d -name node_modules -print 2>/dev/null | sort)
}

build_runtime_path() {
    local workspace_dir="$1"
    local package_dir="$2"
    local entries=()

    if [[ -d "${package_dir}/node_modules/.bin" ]]; then
        entries+=("${package_dir}/node_modules/.bin")
    fi
    if [[ -d "${workspace_dir}/node_modules/.bin" && "${workspace_dir}/node_modules/.bin" != "${package_dir}/node_modules/.bin" ]]; then
        entries+=("${workspace_dir}/node_modules/.bin")
    fi
    if [[ -n "${PATH:-}" ]]; then
        entries+=("${PATH}")
    fi

    if [[ ${#entries[@]} -eq 0 ]]; then
        echo ""
        return 0
    fi

    local path_value=""
    local entry=""
    for entry in "${entries[@]}"; do
        if [[ -z "${path_value}" ]]; then
            path_value="${entry}"
        else
            path_value="${path_value}:${entry}"
        fi
    done
    echo "${path_value}"
}

resolve_package_rel_dir() {
    if [[ -n "${package_rel_dir_hint}" && "${package_rel_dir_hint}" != "." ]]; then
        normalize_rel_dir "${package_rel_dir_hint}"
        return 0
    fi
    if [[ -n "${package_json}" ]]; then
        find_package_rel_dir_for_path "${package_json}"
        return 0
    fi
    if [[ -n "${primary_source}" ]]; then
        find_package_rel_dir_for_path "${primary_source}"
        return 0
    fi
    echo "."
}

resolve_execution_rel_dir() {
    local package_rel_dir="$1"
    case "${working_dir_mode}" in
        workspace)
            echo "."
            ;;
        package)
            echo "${package_rel_dir}"
            ;;
        entry_point)
            if [[ -n "${primary_source}" ]]; then
                find_working_rel_dir_for_path "${primary_source}"
            else
                echo "${package_rel_dir}"
            fi
            ;;
        *)
            echo "${package_rel_dir}"
            ;;
    esac
}

package_rel_dir="$(resolve_package_rel_dir)"
execution_rel_dir="$(resolve_execution_rel_dir "${package_rel_dir}")"

runtime_workspace="$(mktemp -d)"
cleanup_runtime_workspace() {
    rm -rf "${runtime_workspace}"
}

stage_workspace_view "${workspace_root}" "${runtime_workspace}" "${package_rel_dir}"
runtime_package_dir="${runtime_workspace}"
if [[ "${package_rel_dir}" != "." ]]; then
    runtime_package_dir="${runtime_workspace}/${package_rel_dir}"
fi
runtime_exec_dir="${runtime_workspace}"
if [[ "${execution_rel_dir}" != "." ]]; then
    runtime_exec_dir="${runtime_workspace}/${execution_rel_dir}"
fi

workspace_package_map="${runtime_workspace}/.rules_bun_workspace_packages.tsv"
build_workspace_package_map "${runtime_workspace}" "${workspace_package_map}"

primary_node_modules="$(select_primary_node_modules)"
install_repo_root=""
if [[ -n "${primary_node_modules}" ]]; then
    install_repo_root="$(dirname "${primary_node_modules}")"
    mirror_node_modules_dir "${primary_node_modules}" "${runtime_workspace}/node_modules"
fi

if [[ -n "${install_repo_root}" ]]; then
    resolved_install_node_modules="$(find_install_repo_node_modules "${install_repo_root}" "${package_rel_dir}" || true)"
    if [[ -n "${resolved_install_node_modules}" && "${resolved_install_node_modules}" != "${install_repo_root}/node_modules" ]]; then
        mirror_node_modules_dir "${resolved_install_node_modules}" "${runtime_package_dir}/node_modules"
    fi
    mirror_install_repo_workspace_node_modules "${install_repo_root}" "${runtime_workspace}"
fi

if [[ ! -e "${runtime_package_dir}/node_modules" && -e "${runtime_workspace}/node_modules" && "${runtime_package_dir}" != "${runtime_workspace}" ]]; then
    ln -s "${runtime_workspace}/node_modules" "${runtime_package_dir}/node_modules"
fi

runtime_path="$(build_runtime_path "${runtime_workspace}" "${runtime_package_dir}")"
if [[ -n "${runtime_path}" ]]; then
    export PATH="${runtime_path}"
fi
"""

def _shell_quote(value):
    return "'" + value.replace("'", "'\"'\"'") + "'"

def _dirname(path):
    if not path or path == ".":
        return "."

    index = path.rfind("/")
    if index < 0:
        return "."
    if index == 0:
        return "/"
    return path[:index]

def find_install_metadata_file(files):
    for file in files:
        if file.short_path.endswith("node_modules/.rules_bun/install.json"):
            return file
    return None

def resolve_node_modules_roots(files, workspace_dir = ""):
    install_metadata_file = find_install_metadata_file(files)
    shared_node_modules_root = None
    workspace_node_modules_root = None

    if install_metadata_file:
        shared_node_modules_root = _dirname(_dirname(install_metadata_file.path))

    workspace_marker = ""
    if workspace_dir:
        workspace_marker = "/%s/node_modules/" % workspace_dir.strip("/")

    shortest_path = None
    for src in files:
        if workspace_marker and workspace_marker in src.path and workspace_node_modules_root == None:
            workspace_node_modules_root = src.path[:src.path.find(workspace_marker) + len(workspace_marker) - 1]
        if shortest_path == None or len(src.path) < len(shortest_path):
            shortest_path = src.path

    if shared_node_modules_root == None and shortest_path:
        marker = "/node_modules/"
        marker_index = shortest_path.find(marker)
        if marker_index >= 0:
            shared_node_modules_root = shortest_path[:marker_index + len("/node_modules")]

    return struct(
        install_metadata_file = install_metadata_file,
        node_modules_root = workspace_node_modules_root or shared_node_modules_root,
        shared_node_modules_root = shared_node_modules_root,
    )

def create_bun_workspace_info(ctx, primary_file = None, package_json = None, package_dir_hint = ".", extra_files = None):
    direct_runtime_files = []
    if primary_file:
        direct_runtime_files.append(primary_file)
    if package_json and package_json != primary_file:
        direct_runtime_files.append(package_json)
    direct_runtime_files.extend(extra_files or [])

    node_modules_files = depset()
    install_metadata_file = None
    if getattr(ctx.attr, "node_modules", None):
        node_modules_files = ctx.attr.node_modules[DefaultInfo].files
        install_metadata_file = find_install_metadata_file(node_modules_files.to_list())

    metadata_file = ctx.actions.declare_file(ctx.label.name + ".bun_workspace.json")
    ctx.actions.write(
        output = metadata_file,
        content = json.encode({
            "install_metadata": install_metadata_file.short_path if install_metadata_file else "",
            "package_dir_hint": package_dir_hint or ".",
            "package_json": package_json.short_path if package_json else "",
            "primary_file": primary_file.short_path if primary_file else "",
        }) + "\n",
    )
    direct_runtime_files.append(metadata_file)

    runtime_files = depset(
        direct = direct_runtime_files,
        transitive = [node_modules_files],
    )

    return BunWorkspaceInfo(
        install_metadata_file = install_metadata_file,
        metadata_file = metadata_file,
        node_modules_files = node_modules_files,
        package_dir_hint = package_dir_hint or ".",
        package_json = package_json,
        primary_file = primary_file,
        runtime_files = runtime_files,
    )

def workspace_runfiles(ctx, workspace_info, direct_files = None, transitive_files = None):
    return ctx.runfiles(
        files = direct_files or [],
        transitive_files = depset(
            transitive = [workspace_info.runtime_files] + (transitive_files or []),
        ),
    )

def render_workspace_setup(
        bun_short_path,
        working_dir_mode,
        primary_source_short_path = "",
        package_json_short_path = "",
        package_dir_hint = "."):
    return _WORKSPACE_SETUP_TEMPLATE.replace("__BUN_SHORT_PATH__", bun_short_path).replace(
        "__PRIMARY_SOURCE_SHORT_PATH__",
        primary_source_short_path,
    ).replace(
        "__PACKAGE_JSON_SHORT_PATH__",
        package_json_short_path,
    ).replace(
        "__PACKAGE_DIR_HINT__",
        package_dir_hint or ".",
    ).replace(
        "__WORKING_DIR_MODE__",
        working_dir_mode,
    )

