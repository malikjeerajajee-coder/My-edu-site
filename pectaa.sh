#!/bin/bash
set -e
cd ~/my-edu-site 2>/dev/null || cd /public/my-edu-site

echo "════════════════════════════════════════════"
echo "  Importing PECTAA books"
echo "════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────
#  Generate all book JSON files
# ─────────────────────────────────────────────
python3 <<'PYEOF'
import json
import pathlib
import re
import hashlib

BOOKS_DIR = pathlib.Path('src/content/books')
BOOKS_DIR.mkdir(parents=True, exist_ok=True)

# ─────────────────────────────────────────────
#  Raw data: (class, book_name, url)
# ─────────────────────────────────────────────
raw = [
    # ── CLASS 1 (and Pre-primary/Primer) ──
    ('1', 'Primer Mathematics', 'https://drive.google.com/file/d/1d_TTV7hnuw3nDxxm_Qho0mpjEixxWU4F/view'),
    ('1', 'Primer English', 'https://drive.google.com/file/d/1cHA6Vq7swGKmtNPil_rMvAOI41mY_K2L/view'),
    ('1', 'Primer Urdu', 'https://drive.google.com/file/d/1bWIOov-AqNK_ig3Y6YqKUi7LbGPfl4Y4/view'),
    ('1', 'Neela Qaida', 'https://drive.google.com/file/d/12eVQL6knNPkA3CVpJvNIXOYmeYK21Aws/view'),
    ('1', 'Tajveedi Qaida', 'https://drive.google.com/file/d/1ohWq-zOojLu0vPut9zBqUUqoiyY1gFGF/view'),
    ('1', 'Urdu', 'https://drive.google.com/file/d/19n5bsp75ZKdssFn853cl6NW1KdTtQYDR/view'),
    ('1', 'English', 'https://drive.google.com/file/d/1qdIPBXxaVHia6BVInY8uXWmzKkzGZ09Y/view'),
    ('1', 'Mathematics (EM)', 'https://drive.google.com/file/d/1LxW3w4-2xGnZd1ymvz7r3idPD-VFcyCy/view'),
    ('1', 'Waqfiyat-e-Aama (UM)', 'https://drive.google.com/file/d/17yU5hEFQk7tqebZQ_885As4v0T-JRYZY/view'),
    ('1', 'Islamiat (UM)', 'https://drive.google.com/file/d/1xBLpz8Uz-KQwRL6YyW7HDPfUWaxTwYZy/view'),
    ('1', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1e5GPdHGhyfwq-RNjAJVAbXOt6Z3oP70h/view'),
    ('1', 'Buddhism', 'https://drive.google.com/file/d/1BJb0TjePUL2bhwy6w3wxhpPYDJCZ9Ksb/view'),
    ('1', 'Sikhism', 'https://drive.google.com/file/d/1bVDuC1KunhxVmCBKibjO5PEUXWAi2BV2/view'),
    ('1', 'Sanatan Dharam', 'https://drive.google.com/file/d/13nZxZcleYJpiz2tWh1wpvDdnnCWOdyYZ/view'),
    ('1', 'Zoroastrian Religion', 'https://drive.google.com/file/d/1CDyobWg_SkUuGTP4b43UXcUQLm4TMeE4/view'),
    ('1', 'Mashi Taleem', 'https://drive.google.com/file/d/1xffeTVHoaAwHPWOM7G5SnFf3MBWO_zM9/view'),
    ('1', 'Nazra Quran', 'https://drive.google.com/file/d/12c5yKIIjnyVjiV89OOKDGtE-amxkVrfF/view'),

    # ── CLASS 2 ──
    ('2', 'Urdu', 'https://drive.google.com/file/d/1Bv34Yi7RbHaxOYS0M8T8WRm0SsSxyEpB/view'),
    ('2', 'English', 'https://drive.google.com/file/d/1cZ1ACv3BmE26-3Ys8EzrRrMSSXCOfChg/view'),
    ('2', 'Mathematics (EM)', 'https://drive.google.com/file/d/1zmfIo3k_uBTAgCBeXGKdoBy-nfev0dMm/view'),
    ('2', 'Waqfiyat-e-Aama (UM)', 'https://drive.google.com/file/d/1u7FHXHLqFNBQGKOTKM_7DTW92ay2glYl/view'),
    ('2', 'Islamiat (UM)', 'https://drive.google.com/file/d/1ryEzFFcYG32mzZXOazUE4fZcO9mtpv-I/view'),
    ('2', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1tyeA7dylxYzNFqQlF67JNV78tl03l2l4/view'),
    ('2', 'Sikhism', 'https://drive.google.com/file/d/1wLYdteROArTjXxnDGKXNz2XOdT6Q6jyl/view'),
    ('2', 'Sanatan Dharam', 'https://drive.google.com/file/d/1kXhL2azumAgvSPXS7G0CEXVH-rWF_eUu/view'),
    ('2', 'Buddhism', 'https://drive.google.com/file/d/1yOS6Ot4wC8VT5qe0sxOZYxaPmziCYKaF/view'),
    ('2', 'Zoroastrian Religion', 'https://drive.google.com/file/d/1TSBo3tSLg8o_MtDtEjFcD71-LAXVPRCo/view'),
    ('2', 'Mashi Taleem', 'https://drive.google.com/file/d/1S-_w8hhBsO4ihzXUdHnJh7jou3lonHhF/view'),
    ('2', 'Nazra Quran', 'https://drive.google.com/file/d/125VXr4hNUS_90tLX0Vx6aASghIKBcfKI/view'),

    # ── CLASS 3 ──
    ('3', 'Urdu', 'https://drive.google.com/file/d/1eH5o1JLrSCaBeircwfWPiqOp5uwKNP7a/view'),
    ('3', 'English', 'https://drive.google.com/file/d/1WqOqnXmwg6UhfSAzlf4Z-nEQ4GacOdaV/view'),
    ('3', 'Mathematics', 'https://drive.google.com/file/d/1woYnN2ELNGIAaKr3ezMn9v_b9lGoNvYI/view'),
    ('3', 'Waqfiyat-e-Aama (UM)', 'https://drive.google.com/file/d/1Qp2OTjdzhc4mqSh0gQjjIIL7Iwj5toxO/view'),
    ('3', 'Islamiat (UM)', 'https://drive.google.com/file/d/1J-zyPL3_E3wBt7_S-k_hCBuMGFuFlOsE/view'),
    ('3', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1IiZhg6zhdlXAYNz_piPnCb4_wggIFMN2/view'),
    ('3', 'Sikhism', 'https://drive.google.com/file/d/1kuP9iQGtf2yOmatfwk9GMcaMrF3K78gv/view'),
    ('3', 'Sanatan Dharam', 'https://drive.google.com/file/d/1cAs08rXxcGa2yKjsTOqelBH2Pvv-xJ3q/view'),
    ('3', 'Buddhism', 'https://drive.google.com/file/d/1cLYiFDDZYyTXLC3mZ6I-Oj8B9pXelpRb/view'),
    ('3', 'Zoroastrian Religion', 'https://drive.google.com/file/d/1CzafUyXgN3mdk7gCF9dUWv1WkpGeYkqt/view'),
    ('3', 'Mashi Taleem', 'https://drive.google.com/file/d/1AGncn-ymI0cOCY9PCIKOW9W0ZtfYQ7p9/view'),
    ('3', 'Nazra Quran', 'https://drive.google.com/file/d/1Ba8QJM31iXxivUuKZLIAZZJ17PejDENB/view'),

    # ── CLASS 4 ──
    ('4', 'Urdu', 'https://drive.google.com/file/d/1lmfd019QlRWK-ZBJr0Ze7eLPU1PxIbfs/view'),
    ('4', 'English', 'https://drive.google.com/file/d/17RoEMjmPeKHFr7fsSY2DZluFgBBfQtkC/view'),
    ('4', 'Mathematics (EM)', 'https://drive.google.com/file/d/1VRPDFc94NERdu1v2UbP1JNdjxYv3c9XE/view'),
    ('4', 'General Science (EM)', 'https://drive.google.com/file/d/1GeKfK7xrt3OEz1SeeGA6-AO2VeuGLGzx/view'),
    ('4', 'Islamiat (UM)', 'https://drive.google.com/file/d/1mHkh6vLp0us_3Umxr8847KoVyPm88IAe/view'),
    ('4', 'Muasharti Uloom (UM)', 'https://drive.google.com/file/d/13W5CNrAjQZX-1V_PtgyOWoctsHJ0PoOD/view'),
    ('4', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1_E6f2daSK68EXKe4s-JdpzlJWcIJs6ki/view'),
    ('4', 'Zoroastrian Religion', 'https://drive.google.com/file/d/15k45AcrHxD5tag-g9iLM4_IvQcZapPRN/view'),
    ('4', 'Mashi Taleem', 'https://drive.google.com/file/d/1fQFZHH9qH8tuOkmpOeK3_LZi3qwuNgJz/view'),
    ('4', 'Nazra Quran', 'https://drive.google.com/file/d/10seBJAaN5l1CW_sRWKto4WQZRqnKqaFz/view'),

    # ── CLASS 5 ──
    ('5', 'Urdu', 'https://drive.google.com/file/d/1uyNgxCpbP1qzHbEHDBO6ErS8pWkrglcN/view'),
    ('5', 'English', 'https://drive.google.com/file/d/1Z9xfT2L8KKvEfyEifJdODkbs-chlonfF/view'),
    ('5', 'Mathematics (EM)', 'https://drive.google.com/file/d/1RHkqqgGn5q6ZQeyKjHkKJnbavROW2xD8/view'),
    ('5', 'General Science (EM)', 'https://drive.google.com/file/d/13XkS7rDI9c0xhEs3jvnG5lXeg4JbP8UW/view'),
    ('5', 'Islamiat (UM)', 'https://drive.google.com/file/d/1gGkOVvD4VRomHHe-XS-jsQvCaPybncr4/view'),
    ('5', 'Muasharti Uloom (UM)', 'https://drive.google.com/file/d/1VNiEWbBmwJkqydzD1PTbyjaNPGjlwbXG/view'),
    ('5', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1GoMHXY1XOB1O3Z1RFOMY6eWOplgAyP7-/view'),
    ('5', 'Zoroastrian Religion', 'https://drive.google.com/file/d/1XiUlxnJ4OB-YUc5w31loRew-K_pwutuF/view'),
    ('5', 'Mashi Taleem', 'https://drive.google.com/file/d/1OAkYFjF3ku427cGBJMJ7kyHezcsjOi8v/view'),
    ('5', 'Tarjuma Tul Quran', 'https://drive.google.com/file/d/1U-E0-_l_ERWaoomo0KRM3xXRbMNIKheE/view'),

    # ── CLASS 6 ──
    ('6', 'Urdu', 'https://drive.google.com/file/d/1fjKTF0VJ9rGwEwrb1iYMZkuYxu4RmsdA/view'),
    ('6', 'English', 'https://drive.google.com/file/d/1J2WmRQ8acfiz3ZMCoWGisyE9qwnfclKY/view'),
    ('6', 'Islamiat', 'https://drive.google.com/file/d/1sce17Q3P-dyNorHZpSdOTfST5-OMPHce/view'),
    ('6', 'Geography (EM)', 'https://drive.google.com/file/d/1OyJ19YeWpIFt6zjhTrLopJdtZVp2Wd0C/view'),
    ('6', 'History (EM)', 'https://drive.google.com/file/d/1VhVINAr69UPAtnh3h7Ddt_KoHAidCY_4/view'),
    ('6', 'Geography (UM)', 'https://drive.google.com/file/d/1wqc8Zvqk26bxBxyy-lXP1VTjn1xdgObj/view'),
    ('6', 'History (UM)', 'https://drive.google.com/file/d/1ePELIBDXkBxWUvYNwVGaFVwGpTH0EVHS/view'),
    ('6', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1jpoj-jZT16QyDNGw-wCLn3r8WtfP-nOz/view'),

    # ── CLASS 7 ──
    ('7', 'Tarjuma Tul Quran', 'https://drive.google.com/file/d/123L_ClDHd6uH9Sw-83rkAIoGhuEQNomZ/view'),
    ('7', 'Islamiat', 'https://drive.google.com/file/d/1g5mgMgPAcCUB-70JoGNbKk-Vu4cYjteC/view'),
    ('7', 'Arabic', 'https://drive.google.com/file/d/1pzN6br_CJHQ7niuDa3uSYYIr99Yt85T1/view'),
    ('7', 'Urdu', 'https://drive.google.com/file/d/1uqgeKN-J11LdgkNeCiJunDcXMTRirt8a/view'),
    ('7', 'Akhlaqiat (Religious Minorities)', 'https://drive.google.com/file/d/1RRBSrb6SL02Ndn9YcnmUqYCcMoM7IJ5S/view'),
    ('7', 'Geography (EM)', 'https://drive.google.com/file/d/1jcC0QyYAg_j0s_95ukvs-w9-eyLV9qQZ/view'),
    ('7', 'History (EM)', 'https://drive.google.com/file/d/17ByBOJMShn8Mps2dOSMy5t2u7oTseZ59/view'),
    ('7', 'Geography (UM)', 'https://drive.google.com/file/d/1IcRoT1RqG2gwhbyHeO93PKnN3d8_FDCE/view'),
    ('7', 'History (UM)', 'https://drive.google.com/file/d/1UxKj6IhIPmwA3UWV84e-3ZZl-1pN65vg/view'),

    # ── CLASS 8 ──
    ('8', 'Tarjuma Tul Quran', 'https://drive.google.com/file/d/1Gs2TIBIS5TumiHy1WlCm6yDYFyQnGSeH/view'),
    ('8', 'English', 'https://drive.google.com/file/d/1VjslGe1d421x--q0gxAn2l4tYx3zAKF3/view'),
    ('8', 'Mathematics', 'https://drive.google.com/file/d/1nu_CRaFBMu2C5mgJd7Y-ekzOVITP-9rq/view'),
    ('8', 'Geography (EM)', 'https://drive.google.com/file/d/1aMxVwR0tg25ZzUKF17yGYJ6WIqLlh2X1/view'),
    ('8', 'Geography (UM)', 'https://drive.google.com/file/d/13hHZDDx9dDi3spCIMclj7CVkQ1t50eVP/view'),
    ('8', 'History (UM)', 'https://drive.google.com/file/d/1tc4UyYM3fRW_U9XtfmPRMciRgCzZI7N2/view'),
    ('8', 'History (EM)', 'https://drive.google.com/file/d/1hRe3ZTRWQrMEcnWWPJtopp-u5intUob2/view'),
    ('8', 'General Science', 'https://drive.google.com/file/d/14fpAa9TGsayEuMYuwY9gaRU9c_PKky_s/view'),
    ('8', 'Computer Science', 'https://drive.google.com/file/d/1HcurSgdPnqAIuyVzzoKCDk_rGV-t5LsM/view'),
    ('8', 'Urdu', 'https://drive.google.com/file/d/1b_tMiA-YJ3ujhvrQQVJ43MGR3MlQykZh/view'),
    ('8', 'Arabic', 'https://drive.google.com/file/d/1eyir16wfi0C3UegVBo-bAB4C45fqvWdC/view'),

    # ── CLASS 9 ──
    ('9', 'Mathematics (EM) 2020', 'https://pctb.punjab.gov.pk/system/files/2019-G09-Mathematics-EM_0.pdf'),
    ('9', 'Mathematics (UM) 2020', 'https://pctb.punjab.gov.pk/system/files/2019-G09-Math-UM_0.pdf'),
    ('9', 'Mathematics (EM) 2025-26', 'https://drive.google.com/file/d/1IHxM96F221JY3uL4jEIRWQ8NxskXyilF/view'),
    ('9', 'Mathematics (UM) 2025-26', 'https://drive.google.com/file/d/1uSduNMyaebkeOlAis_oh4KUBKssMAT2M/view'),
    ('9', 'Chemistry (EM)', 'https://drive.google.com/file/d/1OY1Unpm8VkLCGQfbLFrE8wLn3fzXmZpc/view'),
    ('9', 'Chemistry (UM)', 'https://drive.google.com/file/d/1nihyc6mbyX0HHbfkGpFzcIUX2-lDJPPP/view'),
    ('9', 'Biology (EM)', 'https://drive.google.com/file/d/1-8dIJw92YsW4BA5EmPinhHMCHRl5WuyX/view'),
    ('9', 'Biology (UM)', 'https://drive.google.com/file/d/1e3G8f_Egp4v5VUiUkZxuk8c-Iomg2QKV/view'),
    ('9', 'Physics (EM)', 'https://drive.google.com/file/d/1Afzgg1sukw1-qBOj61VnMGs6-b1x82ae/view'),
    ('9', 'Physics (UM)', 'https://drive.google.com/file/d/17UbTKUKdiVeK-_AZRFXgqnzBfwjtq92p/view'),
    ('9', 'Computer Science', 'https://drive.google.com/file/d/1C8pGmjCU0swY_N4fhpeVcx_-0oRrEss3/view'),
    ('9', 'Islamiat 2023-24', 'https://drive.google.com/file/d/18XgCH9EanxBp5i2WHI562OPjyIVGdLce/view'),
    ('9', 'Islamiat 2025-26', 'https://drive.google.com/file/d/1kiaCqhXsXuuZ7HAAuXYfjl4_WaBf-ARS/view'),
    ('9', 'Urdu', 'https://drive.google.com/file/d/1anDiX4MZVNmMOzwrwLS7AV0qm5gxO5RF/view'),
    ('9', 'Urdu 2025-26', 'https://drive.google.com/file/d/1JPgnI_hL6D0EMPG36IdjcqB2OFBHLp52/view'),
    ('9', 'English 2023-24', 'https://drive.google.com/file/d/1FINjBKx-C1rlY1EiWGXIsiPVitYMx-5v/view'),
    ('9', 'English 2025-26', 'https://drive.google.com/file/d/1mWBO-wzXqv0Oq9oazcjM-Y16EqmPqBtj/view'),
    ('9', 'Tarjuma Tul Quran', 'https://drive.google.com/file/d/1DMkY84-p4zsQbjKzyGcsTxIXsMGDxOeM/view'),
    ('9', 'Pakistan Studies (EM)', 'https://drive.google.com/file/d/1TQuTcoSw-EUKU76VBHNtleIE3yyuU_C0/view'),
    ('9', 'Pakistan Studies (UM)', 'https://drive.google.com/file/d/1WICBpbpMU375ik-mfH1dGOgHqr1unte6/view'),
    ('9', 'Akhlaqiat 11-12 (Religious Minorities)', 'https://drive.google.com/file/d/1ykzyNur64AqAFF68Q1MxFlfTdDitzalY/view'),
    ('9', 'General Science (EM)', 'https://drive.google.com/file/d/1JpqDG39mhcFxq0cx1pRfx3_lLR6xwsLs/view'),
    ('9', 'General Science (UM)', 'https://drive.google.com/file/d/1kX5PVHh8f2u9r_gUIGewxh2T_xSl3P_e/view'),
    ('9', 'Farsi', 'https://drive.google.com/file/d/1x7_YccQIBcR1Txz9noSfcOWGxNfIyBfh/view'),

    # ── CLASS 10 ──
    ('10', 'English 2026-27', 'https://drive.google.com/file/d/1DIhnZpXMa_5-GiS4KLq9B0ITTAOnPlr4/view'),
    ('10', 'Mathematics 2026-27', 'https://drive.google.com/file/d/1oiEZlsGqnwvAzHgB8Yp1RWi6AnvJ-UE1/view'),
    ('10', 'Urdu 2026-27', 'https://drive.google.com/file/d/1rvX2aIfWwwH_N7V4jsGwMmkpwteDlUmB/view'),
    ('10', 'Mutalia Pakistan', 'https://drive.google.com/file/d/1HeCYkhQimYehdXb6R4vEisIa3qUQtsTt/view'),
    ('10', 'Biology (UM) 2026-27', 'https://drive.google.com/file/d/10Vy5cqKK9eAlv9k-zW6jqjmTJZngUAk-/view'),
    ('10', 'Biology (EM) 2026-27', 'https://drive.google.com/file/d/1-8TsnRfFOQ3JxAT9QXsBGH4Xf5fquZEo/view'),
    ('10', 'Chemistry (UM)', 'https://drive.google.com/file/d/1O30gCpTFypPnG8BR8fsFmYrxEWXOzS17/view'),
    ('10', 'Computer Science', 'https://drive.google.com/file/d/1bfJ7yeruNQ-dKlYeMtCNua2t4k3QbxBU/view'),
    ('10', 'Physics (EM) 2026-27', 'https://drive.google.com/file/d/1uJ52QDD3klP-CwbfXWHlV_d4Y4aTJws5/view'),
    ('10', 'Physics (UM) 2026-27', 'https://drive.google.com/file/d/1BqP9RHrXtqCpZZ1soQcyvJ90ACUSAWar/view'),
    ('10', 'English Grammar and Composition', 'https://drive.google.com/file/d/1SOthleP3bosiOobT5Zwbi0Ceq7J091pc/view'),
    ('10', 'Urdu Quaid-e-Insha 2023-24', 'https://drive.google.com/file/d/18jrYqapYhunZykdWTX4Yl5js8RtCk2Bq/view'),
    ('10', 'Economics (UM) 2023-24', 'https://drive.google.com/file/d/1TYeS-sLBmy1PbZNAQb1v2C2kDgZ4INeK/view'),
    ('10', 'Economics (EM) 2023-24', 'https://drive.google.com/file/d/1TDtLr6-Tb7_qXUHfBbJQarir-MDgHPuK/view'),
    ('10', 'Punjabi Ikhtiari', 'https://drive.google.com/file/d/1jJSG3eMqZRpKHF_-elqDg6zO1ku4zlMQ/view'),
    ('10', 'Civics (UM) 2023-24', 'https://drive.google.com/file/d/117Ixwo3MPOEWOVILaHsRGT5-xfS8hswG/view'),
    ('10', 'Education', 'https://drive.google.com/file/d/17ZwO06Cr3qvzeSwIT_gu6qaLx_sFqWo_/view'),
    ('10', 'Health & Physical Education', 'https://drive.google.com/file/d/1guhX5SdSB4JgSiCgVBfQyBud4K3y-sND/view'),

    # ── CLASS 11 ──
    ('11', 'English', 'https://drive.google.com/file/d/1pGGeTfA_icnSQcNCyw_74UaVLhSXveS8/view'),
    ('11', 'Islamiyat', 'https://drive.google.com/file/d/1YukBznawJyX9QhzxWP6DbmXYHPSzwCRW/view'),
    ('11', 'Urdu', 'https://drive.google.com/file/d/1eBSJe5LtViw1I078FVOT121OGJeljPVb/view'),
    ('11', 'Physics', 'https://drive.google.com/file/d/1l4lEddAJvJ_KjPOaU3hAeBmdZkG6RGiW/view'),
    ('11', 'Mathematics', 'https://drive.google.com/file/d/12KTRPM54MV7_Nc9ifN_kjPMek6wT1oRX/view'),
    ('11', 'Biology', 'https://drive.google.com/file/d/1qEKiX0Gdpr_w2WgA7Ma4URd91UDTBVRk/view'),
    ('11', 'Chemistry', 'https://drive.google.com/file/d/1l-XyH9tA6AQ-DRP9QlUgG8FreYzoHjR3/view'),
    ('11', 'Computer Science', 'https://drive.google.com/file/d/1eWO5ULWhPVDUyBbKX1WM8vymr2YxmYps/view'),
    ('11', 'Civics 2023-24', 'https://drive.google.com/file/d/14uhOVjM1vc7uPc7qv-k6lUNDwUo1v5-K/view'),
    ('11', 'Punjabi Ikhtiari', 'https://drive.google.com/file/d/1WUraJ-KY41PRDW0SyDN_qmf45rOxyHeG/view'),
    ('11', 'Ilm-ul-Taleem', 'https://pctb.punjab.gov.pk/system/files/2018-G11-ILM%20UL%20TALEEM-UM.pdf'),
    ('11', 'Farsi 2020', 'https://drive.google.com/file/d/1e_KZXg31XUKV12V37nbNXQjCr4agJU_Y/view'),
    ('11', 'Psychology (Nafsiyat)', 'https://drive.google.com/file/d/1Nkedemd417cLWoNL488eufMLdtqxohk3/view'),
    ('11', 'Education', 'https://drive.google.com/file/d/1z5ase8yl72_K92ixV5Q_39Jg48TVuLWE/view'),
    ('11', 'Civics', 'https://drive.google.com/file/d/1X6zW61Pi6qNcEaqcSioY1SMluD1v5Aar/view'),
    ('11', 'Tarjuma Tul Quran', 'https://drive.google.com/file/d/1BYO3WE1_zdfx3xdTEtz6h83eTsLfBPdY/view'),
    ('11', 'Urdu 2020', 'https://drive.google.com/file/d/11xFErLIzGIuQgZDShaBLbpkoE2cQxNjz/view'),
    ('11', 'Pakistan Studies (UM)', 'https://drive.google.com/file/d/1p3SUuTOCLqAIOEGbSJdmjDlp7KHIO_0f/view'),
    ('11', 'Pakistan Studies (EM) 2023-24', 'https://drive.google.com/file/d/10yBVAqMslJgrVPyW7QEbSOHwekpukJNJ/view'),
    ('11', 'English Book III 2020', 'https://drive.google.com/file/d/1CKOaS_Xdhif0nCBuN3odRADszw4kxnou/view'),
    ('11', 'English Book I (Short Stories) 2020', 'https://drive.google.com/file/d/1UZWpMZqDULa2LQxOxmS2Kx9xmt9MhpmR/view'),

    # ── CLASS 12 ──
    ('12', 'English', 'https://drive.google.com/file/d/1lQN_8SeOFzuN6PrGBa_D6yPlcYDP_CeZ/view'),
    ('12', 'Urdu', 'https://drive.google.com/file/d/16VYW69kAD2812Nk1tuA1pRhvB7WTyRG1/view'),
    ('12', 'Physics', 'https://drive.google.com/file/d/1j0fVpaaMbChf0LYUdiizmSq5ZKy7myyP/view'),
    ('12', 'Biology', 'https://drive.google.com/file/d/1e5B3_0-RLIhOvw6PPhJ4o6sjuiqgCtb8/view'),
    ('12', 'Mathematics', 'https://drive.google.com/file/d/1Dm1yRrWyxA7xxXvTDQGpu8C5AONdAsPb/view'),
    ('12', 'Computer Science', 'https://drive.google.com/file/d/1EYvLvQlb20T9ZGxL7wcxZhgVJtSf1Rlr/view'),
    ('12', 'Chemistry (EM) 2020', 'https://drive.google.com/file/d/1_3_fJt9AWxRP7AQEmvhVb8n6rOOlqv3q/view'),
    ('12', 'Biology (EM) 2020', 'https://drive.google.com/file/d/1PQMrP44cXssuI1OJDCPE1YPz4dhwi_sY/view'),
    ('12', 'Mathematics 2020', 'https://drive.google.com/file/d/1WDl6Vy0FQ4A10-qyYg6cipaaniWI9CIB/view'),
    ('12', 'Physics 2022', 'https://pctb.punjab.gov.pk/system/files/G12-PHYSICS%20r.pdf'),
    ('12', 'Civics 2023-24', 'https://drive.google.com/file/d/1alJkhKZwl1xcxl067mwF64qUCWUZ1qIM/view'),
    ('12', 'Farsi 2020', 'https://drive.google.com/file/d/1oIRalghgA3KlU9G-Hayzq23W80Dzr-Hj/view'),
    ('12', 'Punjabi Ikhtiari', 'https://drive.google.com/file/d/1k_i-Su8oPQ2h1vQdoSfoqRux5SgYFxBR/view'),
    ('12', 'Ilm-ul-Taleem', 'https://drive.google.com/file/d/18jeujdyMCpyiyVSwI_8F63TUeXXcuQ7t/view'),
    ('12', 'Psychology (Nafsiyat) 2020', 'https://drive.google.com/file/d/1ZRZtic47vymASUoqb6FUZ_R5L12oXObW/view'),
    ('12', 'Mantaq 2020', 'https://drive.google.com/file/d/1327Ux8HGrGzKw-QgI5gwGCxHJZunzdTw/view'),
    ('12', 'Human Geography', 'https://drive.google.com/file/d/1rgv6Ay9gLC1nm4jxD6XJEinoUm0Bqisf/view'),
    ('12', 'Physical Geography', 'https://drive.google.com/file/d/1HoeqZ2S-_BMARpnVl3tp1fhk2dIV8tW1/view'),
    ('12', 'Education', 'https://drive.google.com/file/d/14u09qTHfg0QnbKYVTmcZDR-UUPVdjWSc/view'),
    ('12', 'Sehat-o-Jismani Taleem (UM)', 'https://drive.google.com/file/d/1cHCiX_Pq-4EEB9698otx_OEIjwr65hYC/view'),
    ('12', 'English Grammar and Composition', 'https://drive.google.com/file/d/1MjEGc8wJjMhSyyWFghg_beASRVnEqELb/view'),
    ('12', 'Urdu Quaid-e-Insha', 'https://drive.google.com/file/d/129lEy_rsYLa3CYS_j3s_0I8vnbyc_mG3/view'),
    ('12', 'Home Economics', 'https://drive.google.com/file/d/19Y6fX5qTKvJDxS4k4tPVq3c2cAtbPKTX/view'),
    ('12', 'Workbook Geography', 'https://drive.google.com/file/d/1tJFcwvzPcybHxIxIY9h9UT0pTCAzstsb/view'),
    ('12', 'Statistics 2020', 'https://drive.google.com/file/d/1OfKr3W7ysNLubV4pJT3Rcbzu566mRd_w/view'),
    ('12', 'Economics', 'https://drive.google.com/file/d/1hpdlUNGLZn6LPFIawwUlB3apxin2P6EU/view'),
    ('12', 'Pak Studies (EM)', 'https://drive.google.com/file/d/1TQuTcoSw-EUKU76VBHNtleIE3yyuU_C0/view'),
    ('12', 'Pak Studies (UM)', 'https://drive.google.com/file/d/1WICBpbpMU375ik-mfH1dGOgHqr1unte6/view'),
]

def slugify(s):
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)
    return s.strip('-')

def subject_from_name(name):
    """Extract clean subject name from book name"""
    # Strip year suffixes
    cleaned = re.sub(r'\s*\(?\d{4}[-–]\d{2,4}\)?\s*', ' ', name)
    cleaned = re.sub(r'\s*\(?\d{4}\)?\s*', ' ', cleaned)
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()
    # Remove common prefixes
    cleaned = cleaned.replace('PNB ', '').replace('PNB- ', '')
    return cleaned

def language_suffix(name):
    """Extract EM/UM marker"""
    if '(EM)' in name: return 'EM'
    if '(UM)' in name: return 'UM'
    return ''

created = 0
skipped = 0
seen_hashes = set()

for cls, book_name, url in raw:
    # Skip videos
    if 'elearn.gov.pk' in url or 'Practical Video' in book_name:
        skipped += 1
        continue

    # Skip obvious duplicates (same url + class)
    h = hashlib.md5(f'{cls}:{url}'.encode()).hexdigest()
    if h in seen_hashes:
        skipped += 1
        continue
    seen_hashes.add(h)

    # Clean up title
    subject = subject_from_name(book_name)
    year_match = re.search(r'(\d{4}[-–]\d{2,4}|\d{4})', book_name)
    year_tag = year_match.group(1) if year_match else ''

    # Build title
    title = f'{subject} — Class {cls}'
    if year_tag:
        title = f'{subject} — Class {cls} ({year_tag})'

    # Build slug
    subj_slug = slugify(subject)
    if year_tag:
        subj_slug = f'{subj_slug}-{year_tag.replace("-", "_").replace("–", "_")}'
    filename = f'{cls}-pectaa-{subj_slug}'

    # Skip if this filename already exists
    target = BOOKS_DIR / f'{filename}.json'
    if target.exists():
        skipped += 1
        continue

    data = {
        'title': title,
        'author': 'Punjab Curriculum and Textbook Board (PCTB)',
        'class': cls,
        'subject': subject,
        'boards': ['Punjab'],
        'pdfUrl': url,
    }
    target.write_text(json.dumps(data, indent=2, ensure_ascii=False))
    created += 1

print(f'  ✓ Created {created} book files')
print(f'  · Skipped {skipped} (duplicates or videos)')
print()
print('  Files by class:')
by_class = {}
for cls, _, _ in raw:
    by_class[cls] = by_class.get(cls, 0) + 1
for c in sorted(by_class.keys(), key=int):
    print(f'    Class {c}: {by_class[c]}')
PYEOF

echo ""
echo "Rebuilding (5-8 min)..."
rm -rf .astro node_modules/.vite dist
npm run build 2>&1 | tail -8

echo ""
echo "════════════════════════════════════════════"
echo "  DONE"
echo ""
echo "  Preview:"
echo "    bash start-server.sh"
echo ""
echo "  Check:"
echo "    /My-edu-site/books/"
echo "    /My-edu-site/board/punjab/class-1/books/"
echo "    /My-edu-site/board/punjab/class-9/books/"
echo "    /My-edu-site/board/punjab/class-11/books/"
echo ""
echo "  Push when happy:"
echo "    git add ."
echo "    git commit -m 'Add PECTAA textbooks for Class 1-12'"
echo "    git push"
echo "════════════════════════════════════════════"