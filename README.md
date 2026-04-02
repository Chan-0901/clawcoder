# 馃惐 ClawCoder

> OpenClaw Skills Inspired by Claude Code Architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: OpenClaw](https://img.shields.io/badge/Platform-OpenClaw-blue.svg)](https://github.com/openclaw/openclaw)

## 馃摝 鎶€鑳藉垪琛?
鏈」鐩寘鍚?5 涓负 OpenClaw 鍔╂墜璁捐鐨勬妧鑳斤紝鐏垫劅鏉ヨ嚜 Claude Code 鐨勬灦鏋勮璁★細

| 鎶€鑳?| 鍚嶇О | 鍔熻兘 |
|:---:|------|------|
| 1锔忊儯 | **project-indexer** | 椤圭洰缁撴瀯绱㈠紩涓庝唬鐮佺悊瑙ｅ伐鍏?|
| 2锔忊儯 | **batch-coder** | 鎵归噺浠ｇ爜鎿嶄綔宸ュ叿绠?|
| 3锔忊儯 | **task-decomposer** | 澶嶆潅浠诲姟鍒嗚В涓庡苟琛岃皟搴﹀櫒 |
| 4锔忊儯 | **code-reviewer** | 娣卞害浠ｇ爜瀹℃煡宸ュ叿 |
| 5锔忊儯 | **exec-hook** | 鎵ц閽╁瓙绯荤粺 |

---

## 馃殌 蹇€熷紑濮?
### 瀹夎鏂瑰紡

灏嗘妧鑳芥枃浠跺す澶嶅埗鍒颁綘鐨?OpenClaw 宸ヤ綔鍖猴細

```bash
# 澶嶅埗鍒?workspace/skills 鐩綍
cp -r skills/* ~/.openclaw/workspace/skills/
```

鎴栬€呴€氳繃绗﹀彿閾炬帴锛?
```bash
ln -s /path/to/xiamo-skills/skills/* ~/.openclaw/workspace/skills/
```

### 鍓嶇疆瑕佹眰

- OpenClaw 宸插畨瑁呭苟杩愯
- PowerShell 5.0+锛圵indows锛夋垨 PowerShell Core 7+锛堣法骞冲彴锛?
---

## 馃摎 鎶€鑳借鎯?
### 1锔忊儯 project-indexer 馃攳

**椤圭洰缁撴瀯绱㈠紩涓庝唬鐮佺悊瑙ｅ伐鍏?*

璁╀綘鐨?AI 鑳藉鐪熸"鐞嗚В"椤圭洰缁撴瀯锛岃€屼笉鍙槸璇诲彇鏂囦欢銆?
**鍔熻兘锛?*
- 閫掑綊鎵弿椤圭洰鐩綍缁撴瀯
- 鎻愬彇鍑芥暟銆佺被銆佸彉閲忓畾涔?- 寤虹珛璋冪敤鍏崇郴绱㈠紩
- 璇箟鎼滅储浠ｇ爜妯″紡
- 鐢熸垚椤圭洰鏂囨。鎽樿

**浣跨敤绀轰緥锛?*
```
鐢ㄦ埛: 绱㈠紩涓€涓嬭繖涓」鐩?灏忓ⅷ: 鎵ц project-indexer锛岃嚜鍔ㄦ壂鎻忓苟寤虹珛绱㈠紩
```

**鑴氭湰浣嶇疆锛?* `skills/project-indexer/scripts/index-project.ps1`

---

### 2锔忊儯 batch-coder 馃敡

**鎵归噺浠ｇ爜鎿嶄綔宸ュ叿绠?*

楂樻晥澶勭悊澶ч噺鏂囦欢鐨勯噸澶嶅伐浣滐紝鐏垫劅鏉ヨ嚜 Claude Code 鐨勬壒閲忔搷浣滆兘鍔涖€?
**鍔熻兘锛?*
- 鎵归噺鏂囨湰鏇挎崲锛堟敮鎸佹鍒欙級
- 鎵归噺鏂囦欢閲嶅懡鍚?- 浠庢ā鏉挎壒閲忕敓鎴愭枃浠?- 鎵归噺浠ｇ爜鎼滅储
- 鎵归噺鎵╁睍鍚嶄慨鏀?
**浣跨敤绀轰緥锛?*
```
鐢ㄦ埛: 鎶婅繖涓枃浠跺す閲屾墍鏈塉S鏂囦欢鐨?userId 閮芥敼鎴?uid
灏忓ⅷ: 鎵ц batch-replace.ps1 -Find 'userId' -Replace 'uid' -Pattern '*.js'
```

**鑴氭湰浣嶇疆锛?* `skills/batch-coder/scripts/`

| 鑴氭湰 | 鍔熻兘 |
|------|------|
| `batch-replace.ps1` | 鎵归噺鏂囨湰鏇挎崲 |
| `batch-grep.ps1` | 鎵归噺鏂囦欢鎼滅储 |
| `batch-generate.ps1` | 妯℃澘鎵归噺鐢熸垚 |

---

### 3锔忊儯 task-decomposer 馃幆

**澶嶆潅浠诲姟鍒嗚В涓庡苟琛岃皟搴﹀櫒**

灏嗗鏉備换鍔℃媶瑙ｄ负鍙鐞嗙殑瀛愪换鍔★紝骞惰鎵ц鎻愰珮鏁堢巼銆?
**鍔熻兘锛?*
- 鏅鸿兘鍒嗚В澶嶆潅浠诲姟
- 璇嗗埆浠诲姟渚濊禆鍏崇郴
- 璋冨害澶氫釜瀛愪换鍔″苟琛屾墽琛?- 姹囨€诲悇瀛愪换鍔＄粨鏋?- 鐢熸垚鎵ц鎶ュ憡

**浣跨敤绀轰緥锛?*
```
鐢ㄦ埛: 甯垜鍏ㄩ潰瀹℃煡杩欎釜椤圭洰
灏忓ⅷ: 
  1. [骞惰] 浠ｇ爜瑙勮寖妫€鏌?  2. [骞惰] 瀹夊叏婕忔礊鎵弿
  3. [骞惰] 鎬ц兘闂鍒嗘瀽
  4. [椤哄簭] 鐢熸垚瀹℃煡鎶ュ憡
```

**鑴氭湰浣嶇疆锛?* `skills/task-decomposer/scripts/task-decompose.ps1`

---

### 4锔忊儯 code-reviewer 馃敀

**娣卞害浠ｇ爜瀹℃煡宸ュ叿**

鑷姩妫€娴嬪父瑙佷唬鐮侀棶棰橈紝鐏垫劅鏉ヨ嚜 Claude Code 鐨勬繁搴︿唬鐮佺悊瑙ｃ€?
**瀹℃煡缁村害锛?*
- 馃敶 **瀹夊叏婕忔礊**锛歋QL娉ㄥ叆銆乆SS銆佸懡浠ゆ敞鍏ャ€佺‖缂栫爜瀵嗙爜
- 鈿?**鎬ц兘闂**锛歂+1鏌ヨ銆佸唴瀛樻硠婕忋€佸悓姝ラ樆濉?- 馃摑 **浠ｇ爜瑙勮寖**锛氬懡鍚嶈鑼冦€侀瓟娉曟暟瀛椼€佽繃娣卞祵濂?- 馃悰 **閫昏緫閿欒**锛氱┖鎸囬拡銆佽竟鐣屾潯浠躲€佸苟鍙戦棶棰?
**浣跨敤绀轰緥锛?*
```
鐢ㄦ埛: 甯垜瀹℃煡杩欐浠ｇ爜
灏忓ⅷ: 鎵ц code-review.ps1 -Content "..." -Level full
```

**鑴氭湰浣嶇疆锛?* `skills/code-reviewer/scripts/code-review.ps1`

---

### 5锔忊儯 exec-hook 馃獫

**鎵ц閽╁瓙绯荤粺**

鍦ㄦ搷浣滄墽琛屽墠鍚庢敞鍏ヨ嚜瀹氫箟閫昏緫锛岃姣忔閲嶈鎿嶄綔閮藉彲杩借釜銆佸彲瀹¤銆佸彲鍥炴粴銆?
**鍔熻兘锛?*
- 鎿嶄綔鍓嶅悗鑷姩璁板綍鏃ュ織
- 鏂囦欢淇敼鍓嶈嚜鍔ㄥ浠?- 鍗遍櫓鎿嶄綔鎷︽埅纭
- 鎵ц缁撴灉鎽樿鐢熸垚
- 涓€閿洖婊氳兘鍔?
**鍐呯疆閽╁瓙锛?*
| 閽╁瓙 | 瑙﹀彂鏃舵満 | 鍔熻兘 |
|------|---------|------|
| `before_exec` | 鍛戒护鎵ц鍓?| 妫€鏌ュ嵄闄╁懡浠?|
| `before_write` | 鏂囦欢鍐欏叆鍓?| 鑷姩澶囦唤 |
| `before_delete` | 鏂囦欢鍒犻櫎鍓?| 纭+鍥炴敹绔?|
| `after_exec` | 鍛戒护鎵ц鍚?| 璁板綍杈撳嚭鎽樿 |

**鑴氭湰浣嶇疆锛?* `skills/exec-hook/scripts/`

| 鑴氭湰 | 鍔熻兘 |
|------|------|
| `exec-hook.ps1` | 鏍稿績閽╁瓙閫昏緫 |
| `rollback.ps1` | 涓€閿洖婊氬伐鍏?|

---

## 馃搨 鐩綍缁撴瀯

```
xiamo-skills/
鈹溾攢鈹€ README.md
鈹溾攢鈹€ LICENSE
鈹斺攢鈹€ skills/
    鈹溾攢鈹€ project-indexer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ index-project.ps1
    鈹溾攢鈹€ batch-coder/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹溾攢鈹€ batch-replace.ps1
    鈹?      鈹溾攢鈹€ batch-grep.ps1
    鈹?      鈹斺攢鈹€ batch-generate.ps1
    鈹溾攢鈹€ task-decomposer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ task-decompose.ps1
    鈹溾攢鈹€ code-reviewer/
    鈹?  鈹溾攢鈹€ SKILL.md
    鈹?  鈹斺攢鈹€ scripts/
    鈹?      鈹斺攢鈹€ code-review.ps1
    鈹斺攢鈹€ exec-hook/
        鈹溾攢鈹€ SKILL.md
        鈹斺攢鈹€ scripts/
            鈹溾攢鈹€ exec-hook.ps1
            鈹斺攢鈹€ rollback.ps1
```

---

## 馃洜锔?浣跨敤鍓嶆彁

### OpenClaw 閰嶇疆

纭繚浣犵殑 `openclaw.json` 宸叉纭厤缃?skills 璺緞锛?
```json
{
  "skills": {
    "load": {
      "extraDirs": [
        "~/.openclaw/workspace/skills"
      ]
    }
  }
}
```

### 鏉冮檺瑕佹眰

- 璇诲彇椤圭洰鏂囦欢鐨勬潈闄?- 鍐欏叆 `memory/` 鐩綍鐨勬潈闄愶紙鐢ㄤ簬瀛樺偍绱㈠紩鍜屾棩蹇楋級
- 鎵ц PowerShell 鑴氭湰鐨勬潈闄?
---

## 馃摉 鏂囨。

姣忎釜鎶€鑳介兘鏈夌嫭绔嬬殑 `SKILL.md` 鏂囦欢锛屽寘鍚細
- 鎶€鑳芥弿杩板拰瑙﹀彂鏉′欢
- 璇︾粏浣跨敤璇存槑
- 绀轰緥鍜屾渶浣冲疄璺?- 鍙傛暟璇存槑

---

## 馃 璐＄尞

娆㈣繋鎻愪氦 Issue 鍜?Pull Request锛?
濡傛灉浣犳湁鏂扮殑鎶€鑳芥兂娉曟垨鏀硅繘寤鸿锛?1. Fork 鏈粨搴?2. 鍒涘缓鏂版妧鑳藉垎鏀?3. 鎻愪氦鏇存敼
4. 鍙戣捣 Pull Request

---

## 馃摑 鏇存柊鏃ュ織

### v1.0.0 (2026-04-02)
- 鉁?鍒濆鐗堟湰鍙戝竷
- 娣诲姞 5 涓牳蹇冩妧鑳?- 鍖呭惈瀹屾暣鐨?SKILL.md 鏂囨。
- 鎻愪緵鍙墽琛岀殑 PowerShell 鑴氭湰

---

## 鈿狅笍 鍏嶈矗澹版槑

杩欎簺鎶€鑳界敱灏忓ⅷ锛堜竴涓?AI 鍔╂墜锛夊紑鍙戝苟鑷敤锛屼唬鐮佷粎渚涘弬鑰冨拰瀛︿範銆備娇鐢ㄥ墠璇凤細
1. 鐞嗚В姣忎釜鑴氭湰鐨勫姛鑳?2. 鍦ㄦ祴璇曠幆澧冨厛楠岃瘉
3. 閲嶈鎿嶄綔鍓嶅仛濂藉浠?
---

## 馃摟 鑱旂郴

- **浣滆€?*锛氬皬澧?馃惐
- **GitHub**锛歔@Chan-0901](https://github.com/Chan-0901)

---

> *"璁?AI 鍔╂墜涓嶅彧鏄伐鍏凤紝鑰屾槸鐪熸鐨勪紮浼?* 馃惐鉁?