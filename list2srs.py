#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import json
import glob
import ipaddress
import subprocess
import shutil

RULE_MAP = {
    "DOMAIN": "domain",
    "DOMAIN-SUFFIX": "domain_suffix",
    "DOMAIN-KEYWORD": "domain_keyword",
    "DOMAIN-REGEX": "domain_regex",
    "IP-CIDR": "ip_cidr",
    "IP-CIDR6": "ip_cidr",
    "SRC-IP-CIDR": "source_ip_cidr",
    "SRC-PORT": "source_port",
    "DST-PORT": "port",
    "PROCESS-NAME": "process_name",
    "PROCESS-PATH": "process_path",
}

def is_valid_ip_or_cidr(val):
    try:
        ipaddress.ip_network(val, strict=False)
        return True
    except ValueError:
        return False

def parse_line(line, rules):
    line = line.split('#')[0].split('//')[0].strip()
    if not line:
        return

    if ',' in line:
        parts = [p.strip() for p in line.split(',')]
        rule_type = parts[0].upper()
        if len(parts) < 2:
            return
        value = parts[1]

        if rule_type in RULE_MAP:
            target_key = RULE_MAP[rule_type]
            if target_key in ["port", "source_port"]:
                if value.isdigit():
                    rules[target_key].add(int(value))
            elif target_key == "ip_cidr":
                if is_valid_ip_or_cidr(value):
                    rules[target_key].add(value)
            else:
                rules[target_key].add(value)
        return

    if is_valid_ip_or_cidr(line):
        rules["ip_cidr"].add(line)
    elif line.startswith('+.') or line.startswith('.'):
        rules["domain_suffix"].add(line.lstrip('+.'))
    else:
        rules["domain"].add(line)

def convert_file(list_path, out_dir="dist"):
    rules = {v: set() for v in RULE_MAP.values()}

    with open(list_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            parse_line(line, rules)

    clean_rules = {k: sorted(list(v)) for k, v in rules.items() if v}
    if not clean_rules:
        print(f"⚠️ 跳过空文件或无有效规则: {list_path}")
        return

    srs_data = {
        "version": 2,
        "rules": [clean_rules]
    }

    # 保持原有的相对目录结构输出到 out_dir
    rel_path = os.path.basename(list_path)
    base_name = os.path.splitext(rel_path)[0]
    target_base = os.path.join(out_dir, base_name)
    
    os.makedirs(os.path.dirname(target_base), exist_ok=True)
    
    json_path = f"{target_base}.json"
    srs_path = f"{target_base}.srs"

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(srs_data, f, indent=2, ensure_ascii=False)

    if shutil.which("sing-box"):
        try:
            subprocess.run(
                ["sing-box", "rule-set", "compile", json_path, "-o", srs_path],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            print(f"✅ 成功编译: {list_path} -> {srs_path}")
            os.remove(json_path)  # 编译成功后删除临时 json
        except subprocess.CalledProcessError as e:
            print(f"❌ 编译失败 {json_path}: {e.stderr}")

def main():
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "dist"
    for list_file in glob.glob('**/*.list', recursive=True):
        # 忽略隐藏目录和输出目录本身
        parts = list_file.split(os.sep)
        if any(p.startswith('.') for p in parts if p != '.') or parts[0] == out_dir:
            continue
        convert_file(list_file, out_dir)

if __name__ == '__main__':
    main()
