import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { AnimatePresence, motion } from "framer-motion";
import {
  ArrowLeft,
  BarChart3,
  Bell,
  BookOpen,
  Bus,
  CalendarDays,
  CheckCircle2,
  CloudRain,
  CloudSun,
  Crown,
  Gamepad2,
  HeartPulse,
  Home,
  Landmark,
  ListChecks,
  LockKeyhole,
  LogIn,
  LogOut,
  Mail,
  MoreHorizontal,
  Pencil,
  PlusCircle,
  Save,
  Settings,
  ShoppingBag,
  Shirt,
  Sun,
  Trash2,
  User,
  UserPlus,
  Utensils,
  Wallet,
  Zap,
} from "lucide-react";

const STORAGE_KEY = "simcity-budget-prototype-v1";
const DEMO_DATE = "2026-05-28";
const DEMO_MONTH = "2026-05";
const DEMO_DAY = 28;

const categories = [
  { id: "food", name: "餐饮", icon: Utensils, budget: 800 },
  { id: "entertainment", name: "娱乐", icon: Gamepad2, budget: 300 },
  { id: "study", name: "学习", icon: BookOpen, budget: 300 },
  { id: "daily", name: "日用", icon: ShoppingBag, budget: 400 },
  { id: "traffic", name: "交通", icon: Bus, budget: 200 },
  { id: "clothes", name: "服饰", icon: Shirt, budget: 0 },
  { id: "medical", name: "医疗", icon: HeartPulse, budget: 0 },
  { id: "other", name: "其他", icon: MoreHorizontal, budget: 0 },
];

const initialBills = [
  { id: 1, amount: 35, type: "expense", categoryId: "food", date: DEMO_DATE, remark: "晚餐" },
  { id: 2, amount: 18, type: "expense", categoryId: "traffic", date: DEMO_DATE, remark: "地铁" },
  { id: 3, amount: 128, type: "expense", categoryId: "study", date: "2026-05-27", remark: "资料书" },
  { id: 4, amount: 99, type: "expense", categoryId: "entertainment", date: "2026-05-25", remark: "会员充值" },
  { id: 5, amount: 1200, type: "income", categoryId: "other", date: "2026-05-20", remark: "兼职收入" },
  { id: 6, amount: 62, type: "expense", categoryId: "daily", date: "2026-05-18", remark: "生活用品" },
  { id: 7, amount: 46, type: "expense", categoryId: "food", date: "2026-05-17", remark: "午餐" },
];

const defaultAccount = {
  isLoggedIn: false,
  username: "",
  email: "",
};

const healthMeta = {
  1: {
    name: "繁荣",
    title: "消费克制，小镇繁荣发展",
    desc: "今日消费与累计消费均处于合理范围内。",
    icon: Sun,
    sky: "from-sky-100 via-cyan-50 to-emerald-50",
    town: "高楼 · 喷泉 · 绿地",
    weather: "晴空万里 / 飞鸟动画",
  },
  2: {
    name: "平稳",
    title: "偶有放纵，但总体可控",
    desc: "今日消费偏高，但本月累计仍未突破合理均线。",
    icon: CloudSun,
    sky: "from-stone-100 via-blue-50 to-lime-50",
    town: "民宅 · 平房 · 绿树",
    weather: "多云 / 微风动效",
  },
  3: {
    name: "萧条",
    title: "累计消费超出当前合理进度线",
    desc: "本月总消费还未破预算，但已经超过日均线进度。",
    icon: CloudRain,
    sky: "from-slate-200 via-zinc-100 to-stone-200",
    town: "木屋 · 停工设施 · 枯树",
    weather: "阴天 / 落叶动效",
  },
  4: {
    name: "破产",
    title: "本月预算已被彻底穿透",
    desc: "累计支出已经超过月总预算，需要立即控制消费。",
    icon: Zap,
    sky: "from-slate-800 via-gray-600 to-stone-500",
    town: "废墟 · 帐篷 · 龟裂地面",
    weather: "雷暴雨 / 屏幕震动",
  },
};

function cn(...classes) {
  return classes.filter(Boolean).join(" ");
}

function money(n) {
  return `¥${Number(n || 0).toFixed(2)}`;
}

function getMonthDays() {
  return 31;
}

function categoryOf(id) {
  return categories.find((c) => c.id === id) || categories[categories.length - 1];
}

function calculateHealth(totalBudget, bills, currentDay = DEMO_DAY) {
  const monthDays = getMonthDays();
  const dailyBudget = totalBudget / monthDays;
  const budgetLine = currentDay * dailyBudget;
  const todayExpense = bills
    .filter((bill) => bill.type === "expense" && bill.date === DEMO_DATE)
    .reduce((sum, bill) => sum + bill.amount, 0);
  const totalExpense = bills
    .filter((bill) => bill.type === "expense")
    .reduce((sum, bill) => sum + bill.amount, 0);

  let level = 1;
  if (totalExpense > totalBudget) level = 4;
  else if (totalExpense > budgetLine && totalExpense <= totalBudget) level = 3;
  else if (todayExpense > dailyBudget && totalExpense <= budgetLine) level = 2;

  return {
    level,
    daily: dailyBudget,
    line: budgetLine,
    today: todayExpense,
    total: totalExpense,
    remain: totalBudget - totalExpense,
  };
}

function loadStoredState() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed?.bills) || typeof parsed?.totalBudget !== "number") {
      return null;
    }
    return {
      ...parsed,
      account:
        parsed?.account &&
        typeof parsed.account === "object" &&
        typeof parsed.account.isLoggedIn === "boolean"
          ? {
              isLoggedIn: parsed.account.isLoggedIn,
              username: String(parsed.account.username || ""),
              email: String(parsed.account.email || ""),
            }
          : defaultAccount,
    };
  } catch {
    return null;
  }
}

function Card({ className = "", children }) {
  return (
    <div className={cn("overflow-hidden rounded-[1.75rem] border border-white/70 bg-white/[0.86] shadow-[0_18px_50px_rgba(15,23,42,0.09)] backdrop-blur", className)}>
      {children}
    </div>
  );
}

function CardContent({ className = "", children }) {
  return <div className={className}>{children}</div>;
}

function Button({
  variant = "default",
  size = "default",
  className = "",
  children,
  type = "button",
  ...props
}) {
  const variantClasses = {
    default: "bg-slate-900 text-white hover:bg-slate-800",
    secondary: "bg-slate-200/[0.85] text-slate-900 hover:bg-slate-300/[0.85]",
    ghost: "bg-transparent text-slate-700 hover:bg-white/80",
    destructive: "bg-rose-600 text-white hover:bg-rose-700",
  };
  const sizeClasses = {
    default: "h-11 px-4 py-2",
    icon: "h-10 w-10 p-0",
  };

  return (
    <button
      type={type}
      className={cn(
        "inline-flex items-center justify-center gap-2 whitespace-nowrap font-semibold transition duration-150 focus:outline-none focus:ring-2 focus:ring-slate-400/60 disabled:pointer-events-none disabled:opacity-60",
        variantClasses[variant],
        sizeClasses[size],
        className,
      )}
      {...props}
    >
      {children}
    </button>
  );
}

function PageHeader({ title, subtitle, onBack }) {
  return (
    <div className="flex items-center gap-3 px-5 pt-6 pb-4">
      {onBack && (
        <Button variant="ghost" size="icon" onClick={onBack} className="rounded-full">
          <ArrowLeft className="h-5 w-5" />
        </Button>
      )}
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.28em] text-slate-400">SimCity Budget</p>
        <h1 className="mt-1 text-[1.75rem] font-black tracking-tight text-slate-900">{title}</h1>
        {subtitle && <p className="mt-1 text-sm text-slate-500">{subtitle}</p>}
      </div>
    </div>
  );
}

function StatCard({ icon: Icon, label, value, sub }) {
  return (
    <Card className="rounded-[1.5rem]">
      <CardContent className="p-4">
        <div className="flex items-center gap-3">
          <div className="rounded-2xl bg-slate-100 p-2.5">
            <Icon className="h-5 w-5 text-slate-700" />
          </div>
          <div className="min-w-0">
            <p className="text-xs text-slate-500">{label}</p>
            <p className="truncate text-lg font-black text-slate-900">{value}</p>
            {sub && <p className="line-clamp-2 text-xs text-slate-400">{sub}</p>}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

function SceneStat({ label, value, icon: Icon, sub, accent = "bg-sky-100", bars = "bg-sky-300/85" }) {
  return (
    <div className="relative overflow-hidden rounded-[1.55rem] border border-white/65 bg-white/86 p-4 text-slate-900 shadow-[0_18px_45px_rgba(93,135,189,0.14)] backdrop-blur">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-sm font-semibold text-slate-500">{label}</p>
          <p className="mt-2 truncate text-[1.15rem] font-black tracking-tight text-slate-900">{value}</p>
          {sub && <p className="mt-1 text-xs text-slate-400">{sub}</p>}
        </div>
        <div className={cn("rounded-2xl p-2.5", accent)}>
          <Icon className="h-[1.125rem] w-[1.125rem] text-slate-700" />
        </div>
      </div>
      <div className="mt-4 flex h-8 items-end gap-1.5 opacity-75">
        {[10, 18, 12, 26, 14, 22, 16, 11].map((height, idx) => (
          <span key={`${label}-${idx}`} className={cn("w-2 rounded-full", bars)} style={{ height }} />
        ))}
      </div>
    </div>
  );
}

function TownScene({ level, warning, stats, totalBudget, setPage, onQuickAdd }) {
  const meta = healthMeta[level];
  const WeatherIcon = meta.icon;
  const scene = {
    1: {
      towerTone: "from-sky-200 to-sky-50",
      roofTone: "bg-amber-300/90",
      windowTone: "bg-sky-100/95",
      landTone: "from-lime-200 via-emerald-200 to-lime-100",
      cliffTone: "from-stone-300 to-stone-200",
      roadTone: "bg-slate-600/78",
      stripeTone: "bg-white/85",
      waterTone: "from-cyan-300 via-sky-200 to-blue-100",
      cloudTone: "bg-white/88",
      weatherLabel: "晴空万里",
      temp: "26°C",
      progressTone: "bg-emerald-400",
      cards: ["bg-sky-100", "bg-amber-100", "bg-emerald-100", "bg-violet-100"],
      bars: ["bg-sky-300/85", "bg-orange-300/85", "bg-emerald-300/85", "bg-amber-300/85"],
      birds: true,
      drizzle: false,
      lightning: false,
    },
    2: {
      towerTone: "from-sky-100 to-white",
      roofTone: "bg-slate-300/90",
      windowTone: "bg-sky-50/85",
      landTone: "from-lime-100 via-emerald-100 to-lime-50",
      cliffTone: "from-stone-300 to-stone-100",
      roadTone: "bg-slate-500/72",
      stripeTone: "bg-white/75",
      waterTone: "from-sky-300 via-cyan-100 to-blue-50",
      cloudTone: "bg-white/92",
      weatherLabel: "微风多云",
      temp: "24°C",
      progressTone: "bg-sky-400",
      cards: ["bg-sky-100", "bg-orange-100", "bg-emerald-100", "bg-violet-100"],
      bars: ["bg-sky-300/85", "bg-orange-300/85", "bg-emerald-300/85", "bg-violet-300/85"],
      birds: false,
      drizzle: false,
      lightning: false,
    },
    3: {
      towerTone: "from-slate-200 to-slate-50",
      roofTone: "bg-stone-400/90",
      windowTone: "bg-slate-200/65",
      landTone: "from-lime-100 via-stone-100 to-amber-50",
      cliffTone: "from-stone-400 to-stone-200",
      roadTone: "bg-slate-600/76",
      stripeTone: "bg-white/70",
      waterTone: "from-slate-300 via-sky-100 to-white",
      cloudTone: "bg-slate-100/92",
      weatherLabel: "阴天有风",
      temp: "21°C",
      progressTone: "bg-amber-400",
      cards: ["bg-slate-100", "bg-amber-100", "bg-lime-100", "bg-stone-100"],
      bars: ["bg-slate-300/85", "bg-amber-300/85", "bg-lime-300/85", "bg-stone-300/85"],
      birds: false,
      drizzle: true,
      lightning: false,
    },
    4: {
      towerTone: "from-slate-500 to-stone-500",
      roofTone: "bg-stone-700/95",
      windowTone: "bg-rose-200/25",
      landTone: "from-stone-300 via-stone-200 to-zinc-100",
      cliffTone: "from-stone-500 to-stone-300",
      roadTone: "bg-slate-700/80",
      stripeTone: "bg-white/55",
      waterTone: "from-slate-500 via-sky-200 to-slate-100",
      cloudTone: "bg-slate-200/85",
      weatherLabel: "雷阵暴雨",
      temp: "18°C",
      progressTone: "bg-rose-400",
      cards: ["bg-slate-100", "bg-stone-100", "bg-rose-100", "bg-amber-100"],
      bars: ["bg-slate-300/85", "bg-stone-300/85", "bg-rose-300/85", "bg-amber-300/85"],
      birds: false,
      drizzle: true,
      lightning: true,
    },
  }[level];
  const budgetProgress = totalBudget > 0 ? Math.min(100, Math.max(0, (stats.total / totalBudget) * 100)) : 0;

  return (
    <div className={cn("relative min-h-[calc(100vh-3rem)] overflow-hidden bg-gradient-to-b", meta.sky)}>
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(255,255,255,0.65),transparent_22%),radial-gradient(circle_at_top_right,rgba(255,255,255,0.28),transparent_28%),linear-gradient(180deg,rgba(255,255,255,0.22),transparent_28%)]" />
      <div className="absolute inset-x-0 top-0 h-56 bg-[radial-gradient(circle_at_10%_0%,rgba(255,255,255,0.95),transparent_18%),radial-gradient(circle_at_90%_5%,rgba(255,255,255,0.4),transparent_15%)]" />

      <div className="absolute left-5 right-5 top-6 z-30 flex items-start justify-between gap-4">
        <div className="max-w-[62%] text-slate-900">
          <p className="text-[0.7rem] font-semibold uppercase tracking-[0.34em] text-slate-500">SimCity Budget</p>
          <h1 className="mt-3 text-[2.15rem] font-black leading-tight tracking-tight text-slate-900">模拟城市记账本</h1>
          <p className="mt-2 text-sm leading-6 text-slate-500">让每一笔消费都影响你的小镇命运</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="rounded-[1.75rem] border border-white/70 bg-white/80 px-4 py-3 shadow-[0_18px_38px_rgba(111,154,206,0.16)] backdrop-blur">
            <div className="flex items-center gap-3">
              <div className="rounded-2xl bg-amber-100 p-2.5">
                <WeatherIcon className="h-5 w-5 text-amber-500" />
              </div>
              <div>
                <p className="text-sm font-bold text-slate-700">{scene.weatherLabel}</p>
                <p className="text-sm font-semibold text-slate-500">{scene.temp}</p>
              </div>
            </div>
          </div>
          <button
            type="button"
            className="relative rounded-[1.4rem] border border-white/70 bg-white/80 p-4 shadow-[0_18px_38px_rgba(111,154,206,0.16)] backdrop-blur"
          >
            <Bell className="h-5 w-5 text-slate-700" />
            <span className="absolute right-3 top-3 h-2.5 w-2.5 rounded-full bg-rose-500" />
          </button>
        </div>
      </div>

      <AnimatePresence>
        {warning && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 1, 0.45, 1, 0] }}
            exit={{ opacity: 0 }}
            transition={{ duration: 1.5 }}
            className="absolute inset-0 z-50 flex items-center justify-center bg-slate-950/30 text-white"
          >
            <div className="rounded-3xl border border-white/15 bg-white/16 px-5 py-3 backdrop-blur">
              <div className="flex items-center gap-2 text-sm font-semibold">
                <Zap className="h-5 w-5" />
                分类预算单笔预警
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {level === 4 && (
        <motion.div
          animate={{ x: [0, -3, 3, -2, 2, 0] }}
          transition={{ repeat: Infinity, duration: 1.1 }}
          className="absolute inset-0 pointer-events-none"
        />
      )}

      <div className="absolute inset-0">
        <motion.div
          animate={{ y: [0, -6, 0] }}
          transition={{ repeat: Infinity, duration: 9, ease: "easeInOut" }}
          className={cn("absolute left-[10%] top-[10%] h-20 w-20 rounded-full blur-[1px]", level === 4 ? "bg-amber-100/20" : "bg-amber-100/90")}
        />

        {[0, 1, 2].map((idx) => (
          <motion.div
            key={`cloud-${idx}`}
            animate={{ x: idx % 2 === 0 ? [0, 18, 0] : [0, -14, 0] }}
            transition={{ repeat: Infinity, duration: 7 + idx * 1.5, ease: "easeInOut" }}
            className={cn(
              "absolute rounded-full blur-sm",
              scene.cloudTone,
              idx === 0 && "left-[8%] top-[23%] h-9 w-24",
              idx === 1 && "right-[10%] top-[17%] h-12 w-28",
              idx === 2 && "right-[30%] top-[28%] h-8 w-20",
            )}
          />
        ))}

        {scene.birds && (
          <motion.div
            animate={{ x: [0, 220] }}
            transition={{ repeat: Infinity, duration: 8, ease: "linear" }}
            className="absolute left-10 top-[20%] text-2xl"
          >
            🕊️
          </motion.div>
        )}

        <motion.div
          animate={{ x: [0, 16, 0], y: [0, -8, 0], rotate: [0, 2, 0] }}
          transition={{ repeat: Infinity, duration: 7, ease: "easeInOut" }}
          className="absolute left-[8%] top-[19%] hidden rounded-full border border-white/60 bg-white/82 px-4 py-2 text-sm font-bold text-slate-600 shadow-[0_18px_35px_rgba(111,154,206,0.18)] backdrop-blur md:block"
        >
          记账改变生活
        </motion.div>

        <motion.div
          animate={{ y: [0, -10, 0] }}
          transition={{ repeat: Infinity, duration: 5.5, ease: "easeInOut" }}
          className="absolute right-[6%] top-[24%] text-5xl"
        >
          🎈
        </motion.div>

        {scene.drizzle &&
          [0, 1, 2, 3, 4].map((idx) => (
            <motion.span
              key={`rain-${idx}`}
              animate={{ y: [-10, 150], opacity: [0, 0.6, 0] }}
              transition={{ repeat: Infinity, duration: 1.2 + idx * 0.15, delay: idx * 0.16, ease: "linear" }}
              className="absolute top-[28%] h-10 w-[2px] rounded-full bg-white/40"
              style={{ left: `${22 + idx * 13}%` }}
            />
          ))}

        {scene.lightning && (
          <>
            <motion.div
              animate={{ opacity: [0, 1, 0] }}
              transition={{ repeat: Infinity, duration: 1 }}
              className="absolute right-20 top-[24%] text-3xl"
            >
              ⚡
            </motion.div>
            <motion.div
              animate={{ y: [0, 80] }}
              transition={{ repeat: Infinity, duration: 1.2 }}
              className="absolute left-28 top-[25%] text-2xl"
            >
              🌧️
            </motion.div>
          </>
        )}

        <div className={cn("absolute inset-x-0 bottom-[20%] top-[34%] bg-gradient-to-b", scene.waterTone)}>
          <div className="absolute left-[-10%] bottom-[-3%] h-44 w-40 rounded-full bg-white/32 blur-xl" />
          <div className="absolute right-[-8%] top-[28%] h-36 w-36 rounded-full bg-white/18 blur-xl" />
        </div>

        <motion.div
          initial={{ opacity: 0, y: 24, scale: 0.98 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ duration: 0.45 }}
          className="absolute left-1/2 top-[17%] z-20 h-[52%] w-[92%] -translate-x-1/2"
        >
          <div className={cn("absolute inset-x-0 bottom-0 h-[22%] rounded-[38%] bg-gradient-to-b shadow-[0_28px_60px_rgba(15,23,42,0.15)]", scene.cliffTone)} />
          <div className={cn("absolute inset-x-[2%] bottom-[10%] top-[6%] rounded-[38%] bg-gradient-to-b shadow-[0_24px_50px_rgba(111,154,206,0.2)]", scene.landTone)} />

          <div className="absolute inset-x-[8%] bottom-[16%] top-[16%]">
            <div className={cn("absolute left-[4%] top-[44%] h-7 w-[90%] rounded-full rotate-[-22deg] shadow-sm", scene.roadTone)} />
            <div className={cn("absolute left-[12%] top-[42%] h-2 w-[74%] rounded-full rotate-[-22deg]", scene.stripeTone)} />
            <div className={cn("absolute left-[16%] top-[24%] h-[60%] w-7 rounded-full rotate-[18deg] shadow-sm", scene.roadTone)} />
            <div className={cn("absolute left-[19%] top-[26%] h-[52%] w-2 rounded-full rotate-[18deg]", scene.stripeTone)} />
            <div className={cn("absolute left-[40%] top-[38%] h-24 w-24 rounded-full shadow-[0_18px_30px_rgba(15,23,42,0.12)]", scene.roadTone)} />
            <div className="absolute left-[44%] top-[42%] h-16 w-16 rounded-full bg-white/80">
              <div className="absolute left-1/2 top-1/2 h-9 w-9 -translate-x-1/2 -translate-y-1/2 rounded-full bg-cyan-300/80" />
              <div className="absolute left-1/2 top-[28%] h-7 w-1.5 -translate-x-1/2 rounded-full bg-cyan-50/90" />
              <div className="absolute left-[38%] top-[42%] h-1.5 w-7 rounded-full bg-cyan-50/90" />
            </div>
          </div>

          <div className="absolute left-[40%] top-[20%] h-40 w-24">
            <div className={cn("absolute inset-0 rounded-t-[1.4rem] bg-gradient-to-b shadow-[0_20px_38px_rgba(76,118,176,0.18)]", scene.towerTone)} />
            <div className={cn("absolute inset-x-2 top-3 h-3 rounded-full", scene.roofTone)} />
            <div className="absolute left-1/2 top-[-9%] h-12 w-12 -translate-x-1/2 rounded-full bg-amber-200/85 shadow-[0_0_18px_rgba(255,196,85,0.55)]">
              <span className="absolute inset-0 flex items-center justify-center text-xl">💰</span>
            </div>
            <div className="absolute inset-x-4 top-8 grid grid-cols-2 gap-1.5">
              {Array.from({ length: 10 }).map((_, idx) => (
                <span key={`tower-window-${idx}`} className={cn("h-3 rounded-sm", scene.windowTone)} />
              ))}
            </div>
            <div className="absolute inset-x-[-12%] bottom-0 h-8 rounded-[1rem] bg-white/85 shadow-md" />
          </div>

          <div className="absolute left-[30%] top-[34%] h-24 w-16 rounded-t-[1rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.15)]">
            <div className={cn("absolute inset-x-2 top-2 h-2 rounded-full", scene.roofTone)} />
            <div className="absolute inset-x-3 top-7 grid grid-cols-2 gap-1">
              {Array.from({ length: 6 }).map((_, idx) => (
                <span key={`left-window-${idx}`} className={cn("h-2.5 rounded-sm", scene.windowTone)} />
              ))}
            </div>
          </div>

          <div className="absolute left-[56%] top-[33%] h-28 w-20 rounded-t-[1rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.15)]">
            <div className={cn("absolute inset-x-2 top-2 h-2 rounded-full", scene.roofTone)} />
            <div className="absolute inset-x-3 top-7 grid grid-cols-2 gap-1">
              {Array.from({ length: 8 }).map((_, idx) => (
                <span key={`right-window-${idx}`} className={cn("h-2.5 rounded-sm", scene.windowTone)} />
              ))}
            </div>
          </div>

          <div className="absolute left-[63%] top-[44%] h-[4.5rem] w-14 rounded-t-[0.9rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.15)]">
            <div className={cn("absolute inset-x-2 top-2 h-2 rounded-full", scene.roofTone)} />
            <div className="absolute inset-x-3 top-7 grid grid-cols-2 gap-1">
              {Array.from({ length: 4 }).map((_, idx) => (
                <span key={`mall-window-${idx}`} className={cn("h-2 rounded-sm", scene.windowTone)} />
              ))}
            </div>
            <div className="absolute -bottom-4 left-1/2 w-16 -translate-x-1/2 rounded-xl bg-orange-400 px-2 py-1 text-center text-[0.7rem] font-black text-white shadow-lg">
              MALL
            </div>
          </div>

          <div className="absolute left-[12%] top-[63%] h-16 w-16 rounded-[1rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.12)]">
            <div className="absolute -top-3 left-1/2 h-0 w-0 -translate-x-1/2 border-x-[14px] border-b-[16px] border-x-transparent border-b-sky-300/95" />
          </div>
          <div className="absolute left-[24%] top-[68%] h-14 w-14 rounded-[0.9rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.12)]">
            <div className="absolute -top-2.5 left-1/2 h-0 w-0 -translate-x-1/2 border-x-[12px] border-b-[14px] border-x-transparent border-b-orange-300/95" />
          </div>
          <div className="absolute right-[14%] top-[61%] h-[3.75rem] w-[3.75rem] rounded-[1rem] bg-white/88 shadow-[0_18px_34px_rgba(76,118,176,0.12)]">
            <div className="absolute -top-3 left-1/2 h-0 w-0 -translate-x-1/2 border-x-[13px] border-b-[15px] border-x-transparent border-b-sky-300/95" />
          </div>

          {[0, 1, 2, 3, 4, 5, 6, 7].map((idx) => (
            <div
              key={`tree-${idx}`}
              className={cn(
                "absolute h-10 w-8",
                idx === 0 && "left-[22%] top-[26%]",
                idx === 1 && "left-[74%] top-[30%]",
                idx === 2 && "left-[12%] top-[51%]",
                idx === 3 && "left-[30%] top-[57%]",
                idx === 4 && "left-[72%] top-[58%]",
                idx === 5 && "left-[60%] top-[20%]",
                idx === 6 && "left-[45%] top-[74%]",
                idx === 7 && "left-[82%] top-[51%]",
              )}
            >
              <span className="absolute bottom-0 left-1/2 h-4 w-1 -translate-x-1/2 rounded-full bg-amber-900/45" />
              <span className="absolute left-1/2 top-0 h-7 w-7 -translate-x-1/2 rounded-full bg-emerald-400/80 shadow-[0_6px_10px_rgba(75,154,95,0.25)]" />
            </div>
          ))}

          <div className="absolute left-[80%] top-[22%] h-14 w-14">
            <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 8, ease: "linear" }} className="absolute left-1/2 top-1/2 h-10 w-10 -translate-x-1/2 -translate-y-1/2">
              <span className="absolute left-1/2 top-0 h-10 w-[2px] -translate-x-1/2 rounded-full bg-white/95" />
              <span className="absolute left-0 top-1/2 h-[2px] w-10 -translate-y-1/2 rounded-full bg-white/95" />
              <span className="absolute left-[15%] top-[15%] h-[2px] w-8 rotate-45 rounded-full bg-white/95" />
              <span className="absolute left-[15%] top-[15%] h-[2px] w-8 -rotate-45 rounded-full bg-white/95" />
            </motion.div>
            <span className="absolute left-1/2 top-1/2 h-14 w-1 -translate-x-1/2 rounded-full bg-slate-500/70" />
          </div>

          {level >= 3 && (
            <div className="absolute right-[9%] top-[69%] h-[4.5rem] w-16">
              <span className="absolute bottom-0 left-7 h-[4.5rem] w-1 rounded-full bg-amber-700/80" />
              <span className="absolute left-7 top-2 h-1 w-8 rounded-full bg-amber-700/80" />
              <span className="absolute right-0 top-3 h-7 w-[2px] rounded-full bg-amber-700/80" />
            </div>
          )}

          <div className="absolute left-[-2%] bottom-[8%] h-16 w-10 rounded-full bg-white/70 blur-sm" />
          <div className="absolute left-[5%] bottom-[6%] h-8 w-20 rounded-full bg-cyan-100/90" />
          <div className="absolute left-[10%] bottom-[4%] h-8 w-8 rounded-full bg-white/88 shadow">
            <span className="absolute left-1/2 top-1/2 h-0 w-0 -translate-x-1/2 -translate-y-1/2 border-x-[8px] border-b-[10px] border-x-transparent border-b-orange-200/95" />
          </div>
        </motion.div>

        <div className="absolute left-7 bottom-[29%] z-30 rounded-[1.5rem] border border-white/70 bg-white/84 px-4 py-3 text-slate-800 shadow-[0_18px_36px_rgba(111,154,206,0.16)] backdrop-blur">
          <p className="text-sm font-bold">今日消费</p>
          <p className="mt-1 text-xs text-slate-500">🙂 合理范围内</p>
        </div>

        <div className="absolute right-6 bottom-[25%] z-30 rounded-[1.5rem] border border-white/70 bg-white/84 px-4 py-3 text-right text-slate-800 shadow-[0_18px_36px_rgba(111,154,206,0.16)] backdrop-blur">
          <p className="text-sm font-bold">建设进度</p>
          <p className="mt-1 text-2xl font-black text-slate-900">{budgetProgress.toFixed(0)}%</p>
        </div>
      </div>

      <div className="absolute inset-x-3 bottom-28 z-40">
        <div className="rounded-[2.25rem] border border-white/70 bg-white/70 p-4 shadow-[0_28px_80px_rgba(111,154,206,0.24)] backdrop-blur-xl">
          <div className="grid grid-cols-2 gap-3">
            <SceneStat label="今日支出" value={money(stats.today)} icon={Wallet} sub="合理范围内" accent={scene.cards[0]} bars={scene.bars[0]} />
            <SceneStat label="本月累计" value={money(stats.total)} icon={Landmark} sub={`合理线 ${money(stats.line)}`} accent={scene.cards[1]} bars={scene.bars[1]} />
            <SceneStat label="剩余预算" value={money(stats.remain)} icon={CheckCircle2} sub={`总预算 ${money(totalBudget)}`} accent={scene.cards[2]} bars={scene.bars[2]} />
            <SceneStat label="城市等级" value={meta.name} icon={Crown} sub={meta.title} accent={scene.cards[3]} bars={scene.bars[3]} />
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">
            <Button onClick={onQuickAdd} className="h-14 rounded-[1.55rem] bg-slate-950 text-base shadow-[0_18px_36px_rgba(15,23,42,0.2)]">
              <PlusCircle className="h-5 w-5" />
              记一笔
            </Button>
            <Button onClick={() => setPage("account")} variant="secondary" className="h-14 rounded-[1.55rem] border border-slate-200 bg-white/92 text-base text-slate-900 shadow-[0_18px_36px_rgba(111,154,206,0.12)]">
              <User className="h-5 w-5" />
              账号管理
            </Button>
          </div>

          <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-200/80">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${budgetProgress}%` }}
              className={cn("h-full rounded-full", scene.progressTone)}
            />
          </div>
        </div>
      </div>
    </div>
  );
}

function BillComposer({ onSave, title = "快速记一笔", subtitle = "首页直接完成记账，不再单独跳转页面" }) {
  const [type, setType] = useState("expense");
  const [amount, setAmount] = useState("600");
  const [categoryId, setCategoryId] = useState("entertainment");
  const [date, setDate] = useState(DEMO_DATE);
  const [remark, setRemark] = useState("游戏充值");

  return (
    <Card className="mx-5">
      <CardContent className="space-y-5 p-5">
        <div className="flex items-start justify-between gap-4">
          <div>
            <p className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">Quick Add</p>
            <h2 className="mt-2 text-xl font-black text-slate-900">{title}</h2>
            <p className="mt-1 text-sm text-slate-500">{subtitle}</p>
          </div>
          <div className="rounded-2xl bg-sky-100 p-3">
            <PlusCircle className="h-5 w-5 text-sky-700" />
          </div>
        </div>

        <div>
          <label className="text-sm font-semibold text-slate-700">收支类型</label>
          <div className="mt-2 grid grid-cols-2 gap-3">
            <Button variant={type === "expense" ? "default" : "secondary"} className="rounded-2xl" onClick={() => setType("expense")}>
              支出
            </Button>
            <Button variant={type === "income" ? "default" : "secondary"} className="rounded-2xl" onClick={() => setType("income")}>
              收入
            </Button>
          </div>
        </div>

        <div>
          <label className="text-sm font-semibold text-slate-700">金额</label>
          <div className="mt-2 rounded-3xl bg-slate-50 px-5 py-4 text-4xl font-black text-slate-900">
            <span className="text-xl">¥</span>
            <input
              type="number"
              min="0"
              step="0.01"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              className="ml-2 w-48 bg-transparent outline-none"
            />
          </div>
        </div>

        <div>
          <label className="text-sm font-semibold text-slate-700">消费类别</label>
          <div className="mt-3 grid grid-cols-4 gap-3">
            {categories.map((cat) => {
              const Icon = cat.icon;
              const active = categoryId === cat.id;
              return (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setCategoryId(cat.id)}
                  className={cn(
                    "rounded-2xl p-3 text-center transition",
                    active ? "bg-slate-900 text-white shadow" : "bg-slate-50 text-slate-600",
                  )}
                >
                  <Icon className="mx-auto h-5 w-5" />
                  <p className="mt-1 text-xs">{cat.name}</p>
                </button>
              );
            })}
          </div>
        </div>

        <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <label className="text-sm font-semibold text-slate-700">日期</label>
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              className="mt-2 w-full rounded-2xl bg-slate-50 px-4 py-3 outline-none"
            />
          </div>
          <div>
            <label className="text-sm font-semibold text-slate-700">备注</label>
            <input
              value={remark}
              onChange={(e) => setRemark(e.target.value)}
              className="mt-2 w-full rounded-2xl bg-slate-50 px-4 py-3 outline-none"
            />
          </div>
        </div>

        <Button
          className="h-14 w-full rounded-2xl text-base"
          onClick={() =>
            onSave({
              amount: Number(amount || 0),
              type,
              categoryId,
              date,
              remark,
            })
          }
        >
          <Save className="h-5 w-5" />
          保存账单并刷新首页
        </Button>
      </CardContent>
    </Card>
  );
}

function HomePage({ stats, setPage, healthLevel, warning, totalBudget }) {
  return (
    <div className="relative pb-28">
      <TownScene level={healthLevel} warning={warning} stats={stats} totalBudget={totalBudget} setPage={setPage} onQuickAdd={() => setPage("add")} />
    </div>
  );
}

function AddBillPage({ onBack, onSave }) {
  return (
    <div className="pb-28">
      <PageHeader title="新增账单" subtitle="完成一笔新的收入或支出记录" onBack={onBack} />
      <BillComposer onSave={onSave} title="快速记一笔" subtitle="独立页面完成记账，更符合常见的使用习惯" />
    </div>
  );
}

function BillRow({ bill, onEdit }) {
  const cat = categoryOf(bill.categoryId);
  const Icon = cat.icon;
  return (
    <Card className="rounded-[1.5rem]">
      <CardContent className="flex items-center justify-between p-4">
        <div className="flex items-center gap-3">
          <div className="rounded-2xl bg-slate-100 p-3">
            <Icon className="h-5 w-5 text-slate-700" />
          </div>
          <div>
            <p className="font-bold text-slate-900">
              {cat.name} · {bill.remark || "无备注"}
            </p>
            <p className="text-xs text-slate-500">{bill.date} · 长按可编辑 / 删除</p>
          </div>
        </div>
        <div className="text-right">
          <p className={cn("font-black", bill.type === "income" ? "text-emerald-600" : "text-slate-900")}>
            {bill.type === "income" ? "+" : "-"}
            {money(bill.amount)}
          </p>
          <button type="button" onClick={() => onEdit(bill)} className="mt-1 text-xs text-slate-400">
            详情
          </button>
        </div>
      </CardContent>
    </Card>
  );
}

function BillListPage({ bills, setPage, setEditingBill }) {
  const grouped = bills.reduce((acc, bill) => {
    acc[bill.date] = acc[bill.date] || [];
    acc[bill.date].push(bill);
    return acc;
  }, {});

  return (
    <div className="pb-28">
      <PageHeader title="账单明细" subtitle="按时间流展示当月全部收支记录" />
      <div className="mx-5 mb-4 grid grid-cols-3 gap-3">
        <Button variant="secondary" className="rounded-2xl">
          <CalendarDays className="h-4 w-4" />
          {DEMO_MONTH}
        </Button>
        <Button variant="secondary" className="rounded-2xl">
          支出筛选
        </Button>
        <Button variant="secondary" className="rounded-2xl">
          类别筛选
        </Button>
      </div>
      <div className="mx-5 space-y-5">
        {Object.keys(grouped)
          .sort((a, b) => b.localeCompare(a))
          .map((date) => (
            <div key={date}>
              <p className="mb-2 px-1 text-sm font-bold text-slate-500">{date}</p>
              <div className="space-y-3">
                {grouped[date].map((bill) => (
                  <BillRow
                    key={bill.id}
                    bill={bill}
                    onEdit={(nextBill) => {
                      setEditingBill(nextBill);
                      setPage("detail");
                    }}
                  />
                ))}
              </div>
            </div>
          ))}
      </div>
    </div>
  );
}

function BillDetailPage({ bill, onBack, onDelete }) {
  if (!bill) return null;

  const cat = categoryOf(bill.categoryId);
  const Icon = cat.icon;

  return (
    <div className="pb-28">
      <PageHeader title="账单详情" subtitle="支持查看、编辑和删除当前账单" onBack={onBack} />
      <Card className="mx-5">
        <CardContent className="p-6">
          <div className="flex items-center gap-4">
            <div className="rounded-3xl bg-slate-100 p-4">
              <Icon className="h-8 w-8" />
            </div>
            <div>
              <p className="text-sm text-slate-500">{cat.name}</p>
              <p className="text-4xl font-black text-slate-900">
                {bill.type === "income" ? "+" : "-"}
                {money(bill.amount)}
              </p>
            </div>
          </div>
          <div className="mt-6 space-y-3 rounded-3xl bg-slate-50 p-4 text-sm">
            <div className="flex justify-between">
              <span className="text-slate-500">账单日期</span>
              <span className="font-semibold">{bill.date}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">收支类型</span>
              <span className="font-semibold">{bill.type === "income" ? "收入" : "支出"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">备注</span>
              <span className="font-semibold">{bill.remark || "无"}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-slate-500">创建时间</span>
              <span className="font-semibold">{DEMO_DATE} 21:30</span>
            </div>
          </div>
          <div className="mt-6 grid grid-cols-2 gap-3">
            <Button className="h-12 rounded-2xl" onClick={onBack}>
              <Pencil className="h-4 w-4" />
              返回列表
            </Button>
            <Button variant="destructive" className="h-12 rounded-2xl" onClick={() => onDelete(bill.id)}>
              <Trash2 className="h-4 w-4" />
              删除
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

function AccountPage({ totalBudget, setTotalBudget, account, setAccount }) {
  const [draft, setDraft] = useState(String(totalBudget));
  const [mode, setMode] = useState(account.isLoggedIn ? "profile" : "login");
  const [loginName, setLoginName] = useState(account.username || "simcity_player");
  const [loginPassword, setLoginPassword] = useState("123456");
  const [registerName, setRegisterName] = useState(account.username || "budget_user");
  const [registerEmail, setRegisterEmail] = useState(account.email || "budget@demo.local");
  const [registerPassword, setRegisterPassword] = useState("123456");
  const [savedHint, setSavedHint] = useState("");

  useEffect(() => {
    setDraft(String(totalBudget));
  }, [totalBudget]);

  useEffect(() => {
    if (account.isLoggedIn) {
      setMode("profile");
    }
  }, [account.isLoggedIn]);

  function showHint(text) {
    setSavedHint(text);
    window.setTimeout(() => setSavedHint(""), 1800);
  }

  function handleLogin() {
    const username = loginName.trim() || "simcity_player";
    setAccount({
      isLoggedIn: true,
      username,
      email: account.email || `${username}@demo.local`,
    });
    showHint("已登录到原型账号");
  }

  function handleRegister() {
    const username = registerName.trim() || "budget_user";
    const email = registerEmail.trim() || `${username}@demo.local`;
    setAccount({
      isLoggedIn: true,
      username,
      email,
    });
    showHint("注册成功并已登录");
  }

  function handleLogout() {
    setAccount(defaultAccount);
    setMode("login");
    showHint("已退出当前账号");
  }

  function handleSaveBudget() {
    setTotalBudget(Number(draft || 0));
    showHint("预算设置已更新");
  }

  return (
    <div className="pb-28">
      <PageHeader title="账号管理" subtitle="登录注册、账号信息与预算配置统一管理" />

      <Card className="mx-5">
        <CardContent className="p-5">
          <div className="mb-4 flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">Account Center</p>
              <h2 className="mt-2 text-xl font-black text-slate-900">{account.isLoggedIn ? "当前账号" : "登录 / 注册"}</h2>
            </div>
            {account.isLoggedIn && (
              <span className="rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-700">已登录</span>
            )}
          </div>

          {account.isLoggedIn ? (
            <div className="space-y-4">
              <div className="rounded-[1.75rem] bg-slate-50 p-4">
                <div className="flex items-center gap-4">
                  <div className="flex h-14 w-14 items-center justify-center rounded-3xl bg-slate-900 text-white">
                    <User className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-lg font-black text-slate-900">{account.username}</p>
                    <p className="text-sm text-slate-500">{account.email}</p>
                  </div>
                </div>
                <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
                  <div className="rounded-2xl bg-white p-3">
                    <p className="text-slate-400">账号状态</p>
                    <p className="mt-1 font-bold text-slate-900">本地原型账号</p>
                  </div>
                  <div className="rounded-2xl bg-white p-3">
                    <p className="text-slate-400">数据策略</p>
                    <p className="mt-1 font-bold text-slate-900">设备端本地保存</p>
                  </div>
                </div>
              </div>

              <div className="rounded-[1.5rem] border border-dashed border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-500">
                当前仅为账号管理原型，后续可以接入真实注册、登录、找回密码和云同步能力。
              </div>

              <Button variant="secondary" className="h-12 w-full rounded-2xl" onClick={handleLogout}>
                <LogOut className="h-4 w-4" />
                退出登录
              </Button>
            </div>
          ) : (
            <div>
              <div className="grid grid-cols-2 gap-3 rounded-2xl bg-slate-100 p-1.5">
                <button
                  type="button"
                  onClick={() => setMode("login")}
                  className={cn(
                    "rounded-2xl px-4 py-2 text-sm font-semibold transition",
                    mode === "login" ? "bg-white text-slate-900 shadow-sm" : "text-slate-500",
                  )}
                >
                  登录
                </button>
                <button
                  type="button"
                  onClick={() => setMode("register")}
                  className={cn(
                    "rounded-2xl px-4 py-2 text-sm font-semibold transition",
                    mode === "register" ? "bg-white text-slate-900 shadow-sm" : "text-slate-500",
                  )}
                >
                  注册
                </button>
              </div>

              {mode === "login" ? (
                <div className="mt-5 space-y-4">
                  <div>
                    <label className="text-sm font-semibold text-slate-700">用户名</label>
                    <div className="mt-2 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3">
                      <User className="h-4 w-4 text-slate-400" />
                      <input value={loginName} onChange={(e) => setLoginName(e.target.value)} className="w-full bg-transparent outline-none" />
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-semibold text-slate-700">密码</label>
                    <div className="mt-2 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3">
                      <LockKeyhole className="h-4 w-4 text-slate-400" />
                      <input type="password" value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} className="w-full bg-transparent outline-none" />
                    </div>
                  </div>
                  <Button className="h-12 w-full rounded-2xl" onClick={handleLogin}>
                    <LogIn className="h-4 w-4" />
                    登录账号
                  </Button>
                </div>
              ) : (
                <div className="mt-5 space-y-4">
                  <div>
                    <label className="text-sm font-semibold text-slate-700">用户名</label>
                    <div className="mt-2 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3">
                      <User className="h-4 w-4 text-slate-400" />
                      <input value={registerName} onChange={(e) => setRegisterName(e.target.value)} className="w-full bg-transparent outline-none" />
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-semibold text-slate-700">邮箱</label>
                    <div className="mt-2 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3">
                      <Mail className="h-4 w-4 text-slate-400" />
                      <input value={registerEmail} onChange={(e) => setRegisterEmail(e.target.value)} className="w-full bg-transparent outline-none" />
                    </div>
                  </div>
                  <div>
                    <label className="text-sm font-semibold text-slate-700">密码</label>
                    <div className="mt-2 flex items-center gap-3 rounded-2xl bg-slate-50 px-4 py-3">
                      <LockKeyhole className="h-4 w-4 text-slate-400" />
                      <input type="password" value={registerPassword} onChange={(e) => setRegisterPassword(e.target.value)} className="w-full bg-transparent outline-none" />
                    </div>
                  </div>
                  <Button className="h-12 w-full rounded-2xl" onClick={handleRegister}>
                    <UserPlus className="h-4 w-4" />
                    注册并登录
                  </Button>
                </div>
              )}
            </div>
          )}

          {savedHint && (
            <div className="mt-4 rounded-2xl bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-700">{savedHint}</div>
          )}
        </CardContent>
      </Card>

      <Card className="mx-5 mt-5">
        <CardContent className="space-y-5 p-5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400">Budget Config</p>
              <h2 className="mt-2 text-xl font-black text-slate-900">预算设置</h2>
              <p className="mt-1 text-sm text-slate-500">预算配置已并入账号管理页，方便后续与账号数据统一管理。</p>
            </div>
            <div className="rounded-2xl bg-sky-100 p-3">
              <Settings className="h-5 w-5 text-sky-700" />
            </div>
          </div>

          <div>
            <label className="text-sm font-semibold text-slate-700">当前月份</label>
            <div className="mt-2 rounded-2xl bg-slate-50 px-4 py-3 font-bold text-slate-800">{DEMO_MONTH}</div>
          </div>
          <div>
            <label className="text-sm font-semibold text-slate-700">每月总预算（必填）</label>
            <div className="mt-2 rounded-3xl bg-slate-50 px-5 py-4 text-3xl font-black text-slate-900">
              <span className="text-xl">¥</span>
              <input
                type="number"
                min="0"
                step="1"
                value={draft}
                onChange={(e) => setDraft(e.target.value)}
                className="ml-2 w-48 bg-transparent outline-none"
              />
            </div>
          </div>
          <div>
            <div className="mb-3 flex items-center justify-between">
              <label className="text-sm font-semibold text-slate-700">消费类别预算（选填）</label>
              <span className="text-xs text-slate-400">原型示例仍为静态分类预算</span>
            </div>
            <div className="space-y-3">
              {categories.map((cat) => {
                const Icon = cat.icon;
                return (
                  <div key={cat.id} className="flex items-center justify-between rounded-2xl bg-slate-50 p-3">
                    <div className="flex items-center gap-3">
                      <Icon className="h-5 w-5 text-slate-600" />
                      <span className="font-semibold text-slate-700">{cat.name}</span>
                    </div>
                    <div className="w-28 rounded-xl bg-white px-3 py-2 text-right text-sm font-bold text-slate-800">¥{cat.budget}</div>
                  </div>
                );
              })}
            </div>
          </div>
          <Button className="h-14 w-full rounded-2xl text-base" onClick={handleSaveBudget}>
            保存预算配置
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}

function AnalyticsPage({ stats, bills, totalBudget }) {
  const expenseBills = bills.filter((bill) => bill.type === "expense");
  const income = bills.filter((bill) => bill.type === "income").reduce((sum, bill) => sum + bill.amount, 0);
  const ranked = categories
    .map((cat) => ({
      ...cat,
      spent: expenseBills.filter((bill) => bill.categoryId === cat.id).reduce((sum, bill) => sum + bill.amount, 0),
    }))
    .sort((a, b) => b.spent - a.spent);
  const max = Math.max(...ranked.map((item) => item.spent), 1);

  return (
    <div className="pb-28">
      <PageHeader title="统计分析" subtitle="分类看板与月度统计合并展示" />
      <div className="mx-5 grid grid-cols-2 gap-3">
        <StatCard icon={BarChart3} label="本月总支出" value={money(stats.total)} sub="只统计支出" />
        <StatCard icon={Wallet} label="本月总收入" value={money(income)} sub="不抵扣健康度" />
        <StatCard icon={Sun} label="日均预算" value={money(stats.daily)} sub="月预算 / 月天数" />
        <StatCard icon={Landmark} label="剩余预算" value={money(totalBudget - stats.total)} sub={`合理线 ${money(stats.line)}`} />
      </div>

      <Card className="mx-5 mt-5">
        <CardContent className="p-5">
          <div className="flex items-center justify-between">
            <p className="font-bold text-slate-900">分类预算看板</p>
            <span className="text-xs text-slate-400">预算消耗与超支状态</span>
          </div>
          <div className="mt-4 space-y-3">
            {categories.map((cat) => {
              const Icon = cat.icon;
              const spent = expenseBills
                .filter((bill) => bill.categoryId === cat.id)
                .reduce((sum, bill) => sum + bill.amount, 0);
              const hasBudget = cat.budget > 0;
              const percent = hasBudget ? Math.round((spent / cat.budget) * 100) : 0;
              const status = !hasBudget ? "未设置预算" : percent > 100 ? "已超支" : percent >= 70 ? "接近上限" : "正常";

              return (
                <div key={cat.id} className="rounded-2xl bg-slate-50 p-4">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div className="rounded-2xl bg-white p-3">
                        <Icon className="h-5 w-5 text-slate-700" />
                      </div>
                      <div>
                        <p className="font-bold text-slate-900">{cat.name}</p>
                        <p className="text-xs text-slate-500">
                          已消费 {money(spent)} {hasBudget ? `/ 预算 ${money(cat.budget)}` : ""}
                        </p>
                      </div>
                    </div>
                    <span
                      className={cn(
                        "rounded-full px-3 py-1 text-xs font-semibold",
                        percent > 100
                          ? "bg-rose-100 text-rose-700"
                          : percent >= 70
                            ? "bg-amber-100 text-amber-700"
                            : "bg-emerald-100 text-emerald-700",
                      )}
                    >
                      {status}
                    </span>
                  </div>
                  <div className="mt-4 h-3 overflow-hidden rounded-full bg-white">
                    <motion.div
                      initial={{ width: 0 }}
                      animate={{ width: `${hasBudget ? Math.min(percent, 130) : 0}%` }}
                      className="h-full rounded-full bg-slate-800"
                    />
                  </div>
                  <div className="mt-2 flex justify-between text-xs text-slate-400">
                    <span>0%</span>
                    <span>{hasBudget ? `${percent}%` : "未参与预算预警"}</span>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      <Card className="mx-5 mt-5">
        <CardContent className="p-5">
          <p className="font-bold text-slate-900">分类支出排行</p>
          <div className="mt-4 space-y-4">
            {ranked.slice(0, 6).map((item) => (
              <div key={item.id}>
                <div className="mb-1 flex justify-between text-sm">
                  <span className="font-semibold text-slate-700">{item.name}</span>
                  <span className="text-slate-500">{money(item.spent)}</span>
                </div>
                <div className="h-3 overflow-hidden rounded-full bg-slate-100">
                  <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${(item.spent / max) * 100}%` }}
                    className="h-full rounded-full bg-slate-800"
                  />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

function BottomNav({ page, setPage }) {
  const items = [
    { id: "home", label: "首页", icon: Home },
    { id: "list", label: "账单", icon: ListChecks },
    { id: "analytics", label: "统计", icon: BarChart3 },
    { id: "account", label: "我的", icon: User },
  ];

  return (
    <div className="fixed bottom-4 left-1/2 z-50 w-[min(94%,460px)] -translate-x-1/2 rounded-[2.2rem] border border-white/75 bg-white/[0.92] p-3 shadow-[0_24px_70px_rgba(111,154,206,0.22)] backdrop-blur-xl">
      <div className="grid grid-cols-4 gap-2">
        {items.map((item) => {
          const Icon = item.icon;
          const active = page === item.id;

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => setPage(item.id)}
              className={cn(
                "rounded-[1.45rem] px-2 py-2.5 text-xs font-semibold transition",
                active ? "bg-slate-900 text-white shadow-[0_12px_28px_rgba(15,23,42,0.22)]" : "text-slate-500 hover:bg-slate-50",
              )}
            >
              <Icon className="mx-auto mb-1 h-5 w-5" />
              {item.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}

function App() {
  const stored = loadStoredState();
  const [page, setPage] = useState("home");
  const [bills, setBills] = useState(stored?.bills || initialBills);
  const [totalBudget, setTotalBudgetState] = useState(stored?.totalBudget || 2000);
  const [account, setAccount] = useState(stored?.account || defaultAccount);
  const [editingBill, setEditingBill] = useState(null);
  const [warning, setWarning] = useState(false);
  const stats = useMemo(() => calculateHealth(totalBudget, bills), [totalBudget, bills]);

  useEffect(() => {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        bills,
        totalBudget,
        account,
      }),
    );
  }, [bills, totalBudget, account]);

  function saveBill(input) {
    if (!input.amount) return;

    const cat = categoryOf(input.categoryId);
    const shouldWarn = input.type === "expense" && cat.budget > 0 && input.amount > cat.budget;
    const nextBill = { id: Date.now(), ...input };
    setBills((prev) => [nextBill, ...prev]);

    if (shouldWarn) {
      setWarning(true);
      window.setTimeout(() => setWarning(false), 1600);
    }

    setPage("home");
  }

  function deleteBill(id) {
    setBills((prev) => prev.filter((bill) => bill.id !== id));
    setEditingBill(null);
    setPage("list");
  }

  function updateBudget(nextValue) {
    setTotalBudgetState(nextValue);
  }

  return (
    <div className="min-h-screen bg-transparent px-3 py-6 text-slate-900 sm:px-6">
      <div className="mx-auto min-h-screen max-w-[460px] rounded-[2.5rem] border border-white/60 bg-white/40 shadow-[0_30px_90px_rgba(15,23,42,0.14)] backdrop-blur-xl">
        <AnimatePresence mode="wait">
          <motion.div
            key={page}
            initial={{ opacity: 0, y: 14 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -14 }}
            transition={{ duration: 0.18 }}
          >
            {page === "home" && <HomePage stats={stats} healthLevel={stats.level} setPage={setPage} warning={warning} totalBudget={totalBudget} />}
            {page === "add" && <AddBillPage onBack={() => setPage("home")} onSave={saveBill} />}
            {page === "list" && <BillListPage bills={bills} setPage={setPage} setEditingBill={setEditingBill} />}
            {page === "detail" && <BillDetailPage bill={editingBill} onBack={() => setPage("list")} onDelete={deleteBill} />}
            {page === "analytics" && <AnalyticsPage stats={stats} bills={bills} totalBudget={totalBudget} />}
            {page === "account" && <AccountPage totalBudget={totalBudget} setTotalBudget={updateBudget} account={account} setAccount={setAccount} />}
          </motion.div>
        </AnimatePresence>
        <BottomNav page={page} setPage={setPage} />
      </div>
    </div>
  );
}

const container = document.getElementById("root");

if (container) {
  const root = createRoot(container);
  root.render(
    <React.StrictMode>
      <App />
    </React.StrictMode>,
  );
}
