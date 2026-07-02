# GrowthCare Prototype Map

This file summarizes the current HTML prototype under `reference/html/`.

## Product Areas

GrowthCare is organized around four bottom tabs:
- `预约`
- `接种时间表`
- `成长曲线`
- `我的`

Supporting screens include vaccine details, vaccine add/hide flows, appointment calendar, child/profile editing, clinic management, reminders, and sharing.

## Page Map

| HTML | Role |
| --- | --- |
| `index.html` | Appointment home page, next appointment card, vaccine list, booking flow, edit appointment flow, hide confirmation |
| `接种时间表.html` | Age-based vaccination schedule, current age row highlight, vaccine detail links |
| `疫苗日历.html` | Monthly appointment calendar, child-colored appointment bars and cards |
| `成长曲线.html` | Height/weight growth chart with recorded data overlay |
| `成长记录.html` | Growth record timeline, add entry card, swipe-to-delete |
| `成长记录添加.html` | Add growth record modal, date wheel, height wheel, weight dial |
| `我的.html` | Parent profile, child list, clinic entry, reminder settings, shared members |
| `个人信息.html` | Parent profile edit form |
| `孩子信息.html` | Child profile add/edit form |
| `疫苗添加.html` | Add optional vaccines and restore hidden vaccines |
| `疫苗详情.html` | Vaccine detail shell; content rendered by JS |
| `接种单位.html` | Add clinic page |
| `添加诊所.html` | Add clinic illustration page |
| `提醒日期.html` | Redirect/reference page for reminder date flow |
| `提醒时间.html` | Redirect/reference page for reminder time flow |
| `添加共享成员.html` | Redirect/reference page for shared member flow |
| `疫苗预约时间.html` | Redirect/reference page for booking time modal |
| `疫苗预约门诊.html` | Redirect/reference page for booking clinic modal |
| `疫苗预约门诊选择.html` | Redirect/reference page for clinic selection modal |
| `疫苗预约确认.html` | Redirect/reference page for booking confirmation modal |
| `疫苗修改计划.html` | Redirect/reference page for edit appointment modal |
| `疫苗隐藏确认.html` | Redirect/reference page for hide confirmation modal |

## Shared JavaScript

| File | Role |
| --- | --- |
| `js/baby-profile.js` | Active child, child seed data, child-specific vaccine/growth/calendar data, age formatting, growth timeline |
| `js/vaccine-schedule.js` | Vaccine dose age mapping, schedule rows, due/completed calculations, schedule sorting |
| `js/vaccine-info.js` | Vaccine education content |
| `js/vaccine-detail.js` | Vaccine detail rendering and tabs |
| `js/vaccine-booking-time.js` | Date selection modal for booking |
| `js/vaccine-booking-clinic.js` | Clinic step modal |
| `js/vaccine-booking-clinic-select.js` | Clinic selection list |
| `js/vaccine-booking-confirm.js` | Booking confirmation modal |
| `js/vaccine-booking-remark.js` | Remark editor modal |
| `js/vaccine-edit-plan.js` | Existing appointment edit/delete/complete modal |
| `js/vaccine-hide-confirm.js` | Hide vaccine confirmation modal |
| `js/growth-curve.js` | Growth chart data overlay calculations |
| `js/reminder-date-modal.js` | Custom reminder days wheel |
| `js/reminder-time-modal.js` | Reminder time wheel |
| `js/share-member-modal.js` | Shared member invite modal |
| `js/bottom-nav.js` | Bottom tab icons and selected/unselected states |
| `js/system-time.js` | Live system time, date, weekday formatting |
| `js/modal-animations.js` | Shared modal open/close animation behavior |

## Important State Concepts

Prototype browser storage should be translated into native app models.

| Concept | Prototype source |
| --- | --- |
| Active child | `activeChildId` |
| Child data | `babyProfileChildData` |
| Added vaccines | child `addedVaccines` |
| Hidden vaccines | child `hiddenVaccines` |
| Booked doses | child `bookedDoses` |
| Completed doses | child `completedDoses` |
| Growth records | child `growthRecords` |
| Parent profile | `userProfile` |
| Editable child list in profile page | `childrenList` |
| Shared members | `sharedMembers` |
| Reminder mode | `reminderMode` |
| Custom reminder days | `customReminderDays` |
| Reminder time | `reminderTime` |
| Added clinics | `extraClinics` |

## Initial Child State

Fresh app state creates one placeholder child:
- `孩子1`, birthday set to the current day, default active child

The user can edit the name/birthday or add more children. Child switching affects vaccine status, calendar appointments, and growth records.

## Vaccine Rules

Pinned vaccines:
- `卡介苗`
- `乙肝疫苗`

Pinned vaccines are always visible and cannot be hidden.

Main vaccine list order is defined by `VaccineSchedule.HOME_VACCINE_ORDER`.

Optional vaccines include:
- `五联疫苗`
- `五价轮状疫苗`
- `13价肺炎疫苗`
- `手足口疫苗`
- `水痘疫苗`
- `流感疫苗`

## Main Interaction Flows

### Booking A Dose

1. Tap a future dose on `index.html`.
2. Choose date in booking calendar modal.
3. Confirm or change clinic.
4. Confirm vaccine, date, clinic, and remark.
5. Dose becomes booked and appears in home/calendar.

### Editing A Booking

1. Tap the edit appointment entry on the home page.
2. Existing appointment opens in edit modal.
3. User can delete, complete, edit time, edit clinic, or edit remark.

### Hiding A Vaccine

1. Swipe a vaccine card.
2. Tap hide action.
3. Confirm in hide modal.
4. Vaccine disappears unless it is pinned.

### Growth Record

1. Open `成长记录.html`.
2. Tap add record card.
3. Select date, height, and weight in `成长记录添加.html`.
4. New record appears in timeline and chart.
5. Existing timeline records can be swiped left and deleted.

### Reminder Settings

1. Open `我的.html`.
2. Toggle alarm state.
3. Choose same day, one day, two days, or custom days.
4. Choose reminder time.

## Asset Notes

Use assets from `reference/html/images/` first. Important asset groups:
- Bottom nav icons: `yuyue`, `jiezhongshijianbiao`, `chengzhangquxian`, `wode` and unselected variants
- Dose balls: `yizhongqiu`, `yuyueqiu`, `xuxianqiuyi` through `xuxianqiuwu`
- Child avatars: `avatar-gou`, `avatar-xia`, `unsplash_JfolIjRnveY`
- Growth assets: `height`, `weight`, `growth-line-*`, `growth-shade-*`, height picker assets
- Profile icons: `profile-icon-*`, `profile-avatar-mom`, `profile-toggle-bell`
- Clinic illustration assets: `add-clinic-*`
