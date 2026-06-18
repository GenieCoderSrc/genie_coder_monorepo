import subprocess
import json
import os

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error running command {command}: {result.stderr}")
        return None
    return result.stdout

def get_all_packages():
    output = run_command("melos list --json")
    if not output:
        return []
    return json.loads(output)

def get_dependents(package_name):
    # Find all packages that depend on this specific package
    output = run_command(f"melos list --depends-on={package_name} --include-dependents --json")
    if not output:
        return []
    return json.loads(output)

def main():
    packages = get_all_packages()
    if not packages:
        print("No packages found.")
        return

    dependency_map = {}
    
    print("Mapping dependencies... this may take a moment.")
    for pkg in packages:
        name = pkg['name']
        dependents = get_dependents(name)
        dependency_map[name] = [d['name'] for d in dependents if d['name'] != name]

    with open("DEPENDENCY_MAP.md", "w") as f:
        f.write("# 📦 Package Dependency Map\n\n")
        f.write("This file maps packages to the other packages that depend on them. ")
        f.write("When a package is updated, all its dependents in the list must also be version-bumped.\n\n")
        f.write("| Package | Dependents (Chain) |\n")
        f.write("| :--- | :--- |\n")
        for pkg, deps in sorted(dependency_map.items()):
            deps_str = ", ".join(deps) if deps else "None"
            f.write(f"| {pkg} | {deps_str} |\n")

    print("✅ DEPENDENCY_MAP.md has been generated.")

if __name__ == "__main__":
    main()
