import Foundation

enum VaccineInfoStore {
    static func info(for vaccineName: String) -> VaccineInfo? {
        all[normalizedKey(for: vaccineName)]
    }

    static func normalizedKey(for name: String) -> String {
        if name.contains("乙肝疫苗") { return "乙肝疫苗" }
        if name.contains("卡介") { return "卡介疫苗" }
        if name.contains("脊髓灰质炎") || name.contains("脊灰疫苗") { return "脊灰疫苗" }
        if name.contains("百白破疫苗") { return "百白破" }
        if name.contains("A群脑流") || name.contains("A群流脑") { return "A群流脑" }
        if name.contains("A+C群脑流") { return "A+C结合流脑" }
        if name.contains("AC流脑") || name.contains("A群C群") { return "AC流脑多糖" }
        if name.contains("白破疫苗") { return "白破疫苗" }
        if name.contains("百白破") { return "百白破" }
        if name.contains("五联疫苗") { return "五联疫苗" }
        if name.contains("五价轮状") { return "五价轮状" }
        if name.contains("13价肺炎") { return "13价肺炎" }
        if name.contains("手足口") { return "手足口" }
        if name.contains("麻腮风") { return "麻腮风" }
        if name.contains("乙脑减毒") { return "乙脑减毒" }
        if name.contains("乙脑灭活") { return "乙脑灭活" }
        if name.contains("水痘疫苗") { return "水痘疫苗" }
        if name.contains("甲肝灭活") { return "甲肝灭活" }
        if name.contains("甲肝减毒") { return "甲肝减毒" }
        if name.contains("流感") { return "流感疫苗" }
        return name.replacingOccurrences(of: #"\d+\s*/\s*\d+$"#, with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let all: [String: VaccineInfo] = [
        "乙肝疫苗": VaccineInfo(
            title: "乙肝疫苗",
            intro: "重组乙型肝炎疫苗，是中国国家免疫规划（一类）疫苗，对适龄儿童实行免费接种。它是世界上第一种具有“预防癌症”功能的疫苗，接种后能有效阻断乙肝病毒感染，从而预防由乙肝引起的肝硬化和肝癌。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "出生后24小时内", note: "越早越好，最好在出生后 12 小时内接种"),
                VaccineScheduleInfoRow(dose: "第2针", time: "1月龄", note: "与第 1 针间隔至少 28 天"),
                VaccineScheduleInfoRow(dose: "第3针", time: "6月龄", note: "与第 2 针间隔至少 60 天，与第 1 针间隔至少 4 个月"),
            ],
            reasons: ["乙肝病毒仍然威胁着人们的健康，中国每年仍有超过100万人新发感染该病毒。", "乙型肝炎感染的后果在幼年感染者中往往更为严重。接种乙肝疫苗是预防乙肝最安全、有效的措施。", "乙肝可以通过血液传播。微量血液即可造成感染，日常接触中如共用牙刷或剃须刀。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、疼痛、硬结（通常 1-3 天内消退）。全身轻微发热、头痛、乏力、食欲不振。",
                rare: "过敏性休克（发生率极低，通常在接种后 30 分钟内出现，故接种后须留观）。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种乙肝疫苗未出现过严重过敏反应；对疫苗任何成分（如酵母）无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "慢性疾病急性发作（如严重湿疹、哮喘发作期）", "新生儿体重＜2000g（母亲乙肝表面抗原阳性者除外）"]
                )
            )
        ),
        "卡介疫苗": VaccineInfo(
            title: "卡介苗",
            intro: "卡介苗是预防结核病的疫苗，属于国家免疫规划疫苗，出生后尽早接种。可有效预防儿童严重的结核性脑膜炎和粟粒性肺结核。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "出生后24小时内", note: "未接种者可在 3 月龄前补种"),
            ],
            reasons: ["结核病仍是我国重点防控的传染病，儿童感染后可能发展为严重类型。", "卡介苗对儿童重症结核有良好保护作用。", "尽早接种可尽早获得保护。"],
            sideEffects: VaccineSideEffects(
                common: "接种处出现红肿、结疤，数周至数月内形成卡疤，属正常反应。",
                rare: "局部淋巴结肿大、化脓等，需及时就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病，一般状况良好。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种卡介苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "免疫缺陷或正在接受免疫抑制治疗", "早产儿、低体重儿需经医生评估后接种"]
                )
            )
        ),
        "脊灰疫苗": VaccineInfo(
            title: "脊髓灰质炎疫苗",
            intro: "脊髓灰质炎疫苗用于预防小儿麻痹症（脊灰），是国家免疫规划疫苗。目前采用脊灰灭活疫苗（IPV）与脊灰减毒活疫苗（bOPV）序贯接种程序。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "2月龄", note: "IPV 第 1 剂"),
                VaccineScheduleInfoRow(dose: "第2针", time: "3月龄", note: "IPV 第 2 剂"),
                VaccineScheduleInfoRow(dose: "第3针", time: "4月龄", note: "IPV 第 3 剂"),
                VaccineScheduleInfoRow(dose: "第4针", time: "4岁", note: "bOPV 加强 1 剂"),
            ],
            reasons: ["脊灰病毒可致终身瘫痪，儿童是主要易感人群。", "疫苗接种是全球消灭脊灰的核心手段。", "按时完成全程接种可获得持久保护。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位轻微疼痛、红肿、硬结，一般 1-2 天缓解。",
                rare: "对疫苗成分过敏等极罕见反应。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种脊灰疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "免疫缺陷儿童不宜接种减毒活疫苗（bOPV）", "慢性疾病急性发作期"]
                )
            )
        ),
        "百白破": VaccineInfo(
            title: "百白破疫苗",
            intro: "百白破疫苗是百日咳、白喉、破伤风三种疫苗的联合制剂，属于国家免疫规划疫苗，可有效预防这三种严重传染病。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "3月龄", note: "基础免疫第 1 剂"),
                VaccineScheduleInfoRow(dose: "第2针", time: "4月龄", note: "与上一针间隔至少 28 天"),
                VaccineScheduleInfoRow(dose: "第3针", time: "5月龄", note: "完成基础免疫 3 剂"),
                VaccineScheduleInfoRow(dose: "第4针", time: "18月龄", note: "加强免疫 1 剂"),
            ],
            reasons: ["百日咳对婴幼儿危害大，可致剧烈咳嗽甚至窒息。", "白喉、破伤风可危及生命，疫苗是最有效预防方式。", "联合接种减少针次，提高接种率。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿硬结、低热、哭闹，多数 1-3 天自行缓解。",
                rare: "高热、持续哭闹、过敏反应等，需及时就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种百白破疫苗未出现过严重过敏反应；对疫苗成分（如明胶）无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "有热性惊厥史或神经系统疾病者需医生评估", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "白破疫苗": VaccineInfo(
            title: "白破疫苗",
            intro: "白破疫苗是白喉、破伤风二联疫苗，用于 6 岁儿童加强免疫，补充百白破程序中的白喉和破伤风成分。",
            schedule: [
                VaccineScheduleInfoRow(dose: "加强针", time: "6岁", note: "入学前完成加强接种"),
            ],
            reasons: ["儿童期加强可维持对白喉、破伤风的免疫力。", "破伤风杆菌广泛存在于环境中，疫苗保护至关重要。"],
            sideEffects: VaccineSideEffects(
                common: "局部红肿疼痛、低热，一般短期自行消退。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种白破或百白破疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "慢性疾病急性发作期", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "五联疫苗": VaccineInfo(
            title: "五联疫苗",
            intro: "五联疫苗可同时预防百日咳、白喉、破伤风、脊髓灰质炎和 b 型流感嗜血杆菌（Hib）感染，属自费二类疫苗，可替代部分一类疫苗针次。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "2月龄", note: "最早可 6 周龄开始"),
                VaccineScheduleInfoRow(dose: "第2针", time: "3月龄", note: "与上一针间隔至少 28 天"),
                VaccineScheduleInfoRow(dose: "第3针", time: "4月龄", note: "基础免疫第 3 剂"),
                VaccineScheduleInfoRow(dose: "第4针", time: "18月龄", note: "加强免疫 1 剂"),
            ],
            reasons: ["减少接种针次，从 12 针减少至 4 针，降低宝宝疼痛与不良反应风险。", "Hib 感染可致肺炎、脑膜炎，五联疫苗含 Hib 成分。", "家长可根据需求自愿选择接种。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、低热、烦躁，多数 1-3 天缓解。",
                rare: "持续高热、过敏反应等需就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种同类疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "与一类疫苗程序衔接需咨询接种门诊", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "五价轮状": VaccineInfo(
            title: "五价轮状病毒疫苗",
            intro: "五价轮状病毒疫苗用于预防轮状病毒引起的婴幼儿腹泻，属自费二类疫苗，口服接种。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1剂", time: "2月龄", note: "口服，6-12 周龄开始"),
                VaccineScheduleInfoRow(dose: "第2剂", time: "3月龄", note: "与上一剂间隔 4-10 周"),
                VaccineScheduleInfoRow(dose: "第3剂", time: "4月龄", note: "全程 3 剂，32 周龄前完成"),
            ],
            reasons: ["轮状病毒是婴幼儿严重腹泻最常见原因之一。", "口服疫苗使用方便，可显著降低住院风险。"],
            sideEffects: VaccineSideEffects(
                common: "轻微腹泻、呕吐、低热，通常短暂。",
                rare: "肠套叠风险极低，出现异常哭闹、血便需就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无呕吐、腹泻等急性疾病，一般状况良好。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种轮状病毒疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "严重免疫缺陷、肠套叠史者不宜接种", "口服前后 30 分钟内避免热饮"]
                )
            )
        ),
        "13价肺炎": VaccineInfo(
            title: "13价肺炎球菌结合疫苗",
            intro: "13价肺炎球菌结合疫苗（PCV13）用于预防肺炎球菌引起的肺炎、脑膜炎、菌血症等，属自费二类疫苗。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "2月龄", note: "6 周龄可开始"),
                VaccineScheduleInfoRow(dose: "第2针", time: "4月龄", note: "间隔至少 28 天"),
                VaccineScheduleInfoRow(dose: "第3针", time: "6月龄", note: "基础免疫 3 剂"),
                VaccineScheduleInfoRow(dose: "第4针", time: "12-15月龄", note: "加强 1 剂"),
            ],
            reasons: ["肺炎球菌是儿童社区获得性肺炎的重要病原。", "婴幼儿免疫系统未成熟，是感染高危人群。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、低热、嗜睡，一般 1-2 天缓解。",
                rare: "持续高热、过敏反应等需就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种肺炎球菌疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "慢性疾病急性发作期", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "A群流脑": VaccineInfo(
            title: "A群流脑多糖疫苗",
            intro: "A群流脑疫苗用于预防 A 群脑膜炎球菌引起的流行性脑脊髓膜炎，属于国家免疫规划疫苗。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "6月龄", note: "基础免疫第 1 剂"),
                VaccineScheduleInfoRow(dose: "第2针", time: "9月龄", note: "与第 1 针间隔至少 3 个月"),
            ],
            reasons: ["流脑起病急、进展快，儿童是高发人群。", "疫苗可显著降低流脑发病率。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、低热，一般短期消退。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种流脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "慢性疾病急性发作期", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "A+C结合流脑": VaccineInfo(
            title: "A群C群流脑结合疫苗",
            intro: "A群C群流脑结合疫苗可同时预防 A 群和 C 群脑膜炎球菌感染，属自费二类疫苗，免疫记忆更好。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "6月龄", note: "具体程序依产品说明"),
                VaccineScheduleInfoRow(dose: "第2针", time: "9月龄", note: "与 A 群流脑不可重复接种，需二选一"),
            ],
            reasons: ["C 群流脑在我国部分省份仍有流行风险。", "结合疫苗可产生更好免疫记忆。"],
            sideEffects: VaccineSideEffects(
                common: "局部红肿、低热，多数 1-2 天缓解。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种流脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "与 A 群流脑疫苗不可重复接种，需咨询门诊选择其一", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "AC流脑多糖": VaccineInfo(
            title: "A群C群流脑多糖疫苗",
            intro: "A群C群流脑多糖疫苗用于加强预防 A 群和 C 群脑膜炎球菌引起的流行性脑脊髓膜炎，属于国家免疫规划疫苗。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "3岁", note: "与 A 群流脑第 2 剂间隔至少 12 个月"),
                VaccineScheduleInfoRow(dose: "第2针", time: "6岁", note: "与第 1 针间隔至少 3 年"),
            ],
            reasons: ["加强免疫可维持对流脑的保护力。", "学龄前完成加强有助于集体防护。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位轻微反应、低热。",
                rare: "极罕见过敏等反应。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种流脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "2 岁以下儿童不适用多糖疫苗加强程序", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "ACYW135多糖": VaccineInfo(
            title: "ACYW135群流脑多糖疫苗",
            intro: "ACYW135 群流脑多糖疫苗可预防 A、C、Y、W135 群脑膜炎球菌感染，通常属于非免疫规划疫苗，是否接种需结合当地风险和接种门诊建议。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "2岁及以上", note: "按产品说明书和门诊建议接种"),
                VaccineScheduleInfoRow(dose: "加强针", time: "按需", note: "高风险地区或特殊暴露风险需医生评估"),
            ],
            reasons: ["覆盖更多血清群，扩大保护范围。", "适用于流脑高发地区的加强免疫。"],
            sideEffects: VaccineSideEffects(
                common: "局部红肿、低热，短期自行缓解。",
                rare: "过敏反应极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种流脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "3 岁以下不适用", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "手足口": VaccineInfo(
            title: "EV71手足口病疫苗",
            intro: "EV71 型手足口病疫苗用于预防 EV71 感染所致的手足口病及相关重症，属自费二类疫苗。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "6月龄", note: "6 月龄-5 岁可接种"),
                VaccineScheduleInfoRow(dose: "第2针", time: "7月龄", note: "与第 1 针间隔至少 28 天"),
            ],
            reasons: ["EV71 是引起重症手足口病的主要病原体。", "疫苗可显著降低重症和死亡风险。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、低热、食欲下降，一般 1-3 天缓解。",
                rare: "持续高热、过敏反应需就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种 EV71 疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "5 岁前需完成 2 剂", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "麻腮风": VaccineInfo(
            title: "麻腮风联合疫苗",
            intro: "麻腮风疫苗是麻疹、腮腺炎、风疹三联疫苗，属于国家免疫规划疫苗，一次接种预防三种传染病。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "8月龄", note: "基础免疫"),
                VaccineScheduleInfoRow(dose: "第2针", time: "18月龄", note: "加强免疫，与第 1 针间隔至少 28 天"),
            ],
            reasons: ["麻疹传染性强，可致肺炎、脑炎等严重并发症。", "腮腺炎可影响生育功能，风疹对孕妇危害大。", "全程两剂是建立群体免疫的关键。"],
            sideEffects: VaccineSideEffects(
                common: "低热、皮疹、局部红肿，一般 5-10 天自行缓解。",
                rare: "高热惊厥、过敏反应等需就医。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种麻腮风疫苗未出现过严重过敏反应；对疫苗成分（如明胶、鸡蛋蛋白）无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "免疫缺陷者禁用减毒活疫苗", "慢性疾病急性发作期"]
                )
            )
        ),
        "乙脑减毒": VaccineInfo(
            title: "乙型脑炎减毒活疫苗",
            intro: "乙脑减毒活疫苗用于预防流行性乙型脑炎，属于国家免疫规划疫苗，由蚊子传播，夏季高发。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "8月龄", note: "基础免疫"),
                VaccineScheduleInfoRow(dose: "第2针", time: "2岁", note: "加强 1 剂"),
            ],
            reasons: ["乙脑严重时可致高热、抽搐、昏迷甚至死亡。", "儿童是乙脑主要受害者，疫苗是最有效防护。"],
            sideEffects: VaccineSideEffects(
                common: "低热、局部红肿，一般 1-3 天缓解。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种乙脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "免疫缺陷者禁用减毒活疫苗", "慢性疾病急性发作期"]
                )
            )
        ),
        "乙脑灭活": VaccineInfo(
            title: "乙型脑炎灭活疫苗",
            intro: "乙脑灭活疫苗用于预防流行性乙型脑炎，采用灭活病毒制备，适用于不宜接种减毒活疫苗的儿童。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "8月龄", note: "基础免疫第 1 剂"),
                VaccineScheduleInfoRow(dose: "第2针", time: "8月龄", note: "与第 1 针间隔 7-10 天"),
                VaccineScheduleInfoRow(dose: "第3针", time: "2岁", note: "加强免疫 1 剂"),
                VaccineScheduleInfoRow(dose: "第4针", time: "6岁", note: "加强免疫 1 剂"),
            ],
            reasons: ["乙脑是夏秋季常见的中枢神经系统传染病。", "灭活疫苗安全性较好，适合特殊人群。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红肿、低热，多数短期消退。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种乙脑疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "与减毒活疫苗不可同时程序接种，需咨询门诊", "慢性疾病急性发作期"]
                )
            )
        ),
        "水痘疫苗": VaccineInfo(
            title: "水痘疫苗",
            intro: "水痘疫苗用于预防水痘及带状疱疹（成人期），属自费二类疫苗，部分省市已纳入免费。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "12月龄", note: "12 月龄以上可接种"),
                VaccineScheduleInfoRow(dose: "第2针", time: "4岁", note: "与第 1 针间隔至少 3 个月"),
            ],
            reasons: ["水痘传染性强，可致皮肤感染、肺炎等并发症。", "接种可减轻病情并降低并发症风险。"],
            sideEffects: VaccineSideEffects(
                common: "低热、少量皮疹，一般轻微。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病，未处于水痘发病期。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种水痘疫苗未出现过严重过敏反应；对疫苗成分（如明胶）无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "正在发水痘者不宜接种", "免疫缺陷者需经医生评估"]
                )
            )
        ),
        "甲肝灭活": VaccineInfo(
            title: "甲肝灭活疫苗",
            intro: "甲肝灭活疫苗用于预防甲型肝炎，属自费二类疫苗，通过灭活病毒制备，安全性较好。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "18月龄", note: "18 月龄以上"),
                VaccineScheduleInfoRow(dose: "第2针", time: "24月龄", note: "与第 1 针间隔 6-12 个月"),
            ],
            reasons: ["甲肝经口传播，儿童易感，可致急性肝炎。", "疫苗可有效预防感染。"],
            sideEffects: VaccineSideEffects(
                common: "局部红肿、低热，短期消退。",
                rare: "过敏反应极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种甲肝疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "与甲肝减毒疫苗二选一，不可重复接种", "上次接种出现严重不良反应者暂缓"]
                )
            )
        ),
        "甲肝减毒": VaccineInfo(
            title: "甲肝减毒活疫苗",
            intro: "甲肝减毒活疫苗是国家免疫规划疫苗，只需接种 1 剂即可产生持久保护，预防甲型肝炎。",
            schedule: [
                VaccineScheduleInfoRow(dose: "第1针", time: "18月龄", note: "18 月龄接种 1 剂"),
            ],
            reasons: ["甲肝是常见儿童肝病之一，可经食物、水源传播。", "一剂程序简便，保护效果良好。"],
            sideEffects: VaccineSideEffects(
                common: "局部轻微反应、低热。",
                rare: "过敏反应等极罕见。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热（体温＜37.5℃）、无感冒、腹泻等急性疾病。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种甲肝疫苗未出现过严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请恢复健康后补种：",
                    items: ["发热、急性疾病", "与甲肝灭活疫苗不可同时程序接种", "免疫缺陷者禁用减毒疫苗"]
                )
            )
        ),
        "流感疫苗": VaccineInfo(
            title: "流感疫苗",
            intro: "流感疫苗用于预防流行性感冒及其相关并发症。6 月龄及以上且无接种禁忌的人群可接种，儿童、老年人和慢性病患者等人群通常更需要保护。",
            schedule: [
                VaccineScheduleInfoRow(dose: "首次接种", time: "6月龄-8岁", note: "首次接种灭活流感疫苗通常需 2 剂，间隔至少 4 周"),
                VaccineScheduleInfoRow(dose: "年度接种", time: "每年", note: "既往接种过者通常每个流感季接种 1 剂"),
            ],
            reasons: ["流感传染性强，儿童感染后可能出现高热、肺炎等并发症。", "每年接种可帮助降低感染、重症和就医风险。", "流感病毒容易变异，保护需要随流行季及时更新。"],
            sideEffects: VaccineSideEffects(
                common: "接种部位红晕、肿胀、硬结、疼痛，或短暂发热、乏力、头痛等，通常较轻并可自行缓解。",
                rare: "严重过敏反应等极罕见，接种后应按要求现场留观。"
            ),
            precautions: VaccinePrecautions(
                health: VaccinePrecautionBlock(title: "健康状况正常", text: "宝宝无发热、急性疾病或慢性疾病急性发作。轻中度急性疾病建议恢复后再接种。"),
                allergy: VaccinePrecautionBlock(title: "无严重过敏史", text: "既往接种流感疫苗未出现严重过敏反应；对疫苗成分无已知严重过敏。"),
                delay: VaccineDelayPrecaution(
                    title: "暂缓接种情况",
                    intro: "如有以下情况，请咨询接种门诊评估：",
                    items: ["发热、急性疾病或慢性疾病急性发作", "既往接种流感疫苗出现严重不良反应", "有未控制的癫痫或其他进行性神经系统疾病"]
                )
            )
        ),
    ]
}
