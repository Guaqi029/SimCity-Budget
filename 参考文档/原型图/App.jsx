import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { AnimatePresence, motion } from "framer-motion";
import {
  AlertTriangle,
  ArrowLeft,
  BarChart3,
  BookOpen,
  Bus,
  CalendarDays,
  CheckCircle2,
  CloudRain,
  CloudSun,
  Gamepad2,
  HeartPulse,
  Home,
  Landmark,
  ListChecks,
  MoreHorizontal,
  Pencil,
  PieChart,
  PlusCircle,
  Save,
  Settings,
  ShoppingBag,
  Shirt,
  Sun,
  Trash2,
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
    return parsed;
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

function TownScene({ level, warning }) {
  const meta = healthMeta[level];
  const Icon = meta.icon;
  const buildings = {
    1: ["h-24", "h-32", "h-20", "h-28", "h-36"],
    2: ["h-[4.5rem]", "h-24", "h-16", "h-[5.5rem]", "h-20"],
    3: ["h-14", "h-20", "h-12", "h-16", "h-10"],
    4: ["h-8", "h-12", "h-6", "h-10", "h-7"],
  }[level];

  return (
    <div className={cn("relative mx-5 overflow-hidden rounded-[2rem] bg-gradient-to-br p-5 shadow-[0_22px_60px_rgba(15,23,42,0.18)]", meta.sky)}>
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_left,rgba(255,255,255,0.55),transparent_40%)]" />
      <div className="absolute right-5 top-5 rounded-full bg-white/75 p-3 shadow-sm backdrop-blur">
        <Icon className="h-7 w-7 text-slate-700" />
      </div>

      <AnimatePresence>
        {warning && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 1, 0.45, 1, 0] }}
            exit={{ opacity: 0 }}
            transition={{ duration: 1.5 }}
            className="absolute inset-0 z-20 flex items-center justify-center bg-slate-900/45 text-white"
          >
            <div className="rounded-3xl bg-white/20 px-5 py-3 backdrop-blur">
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

      <div className="relative mb-8 mt-4 max-w-[72%]">
        <p className="text-sm font-medium text-slate-600">当前小镇状态</p>
        <h2 className="mt-1 text-3xl font-black text-slate-900">{meta.name}</h2>
        <p className="mt-2 text-sm leading-6 text-slate-600">{meta.title}</p>
      </div>

      <div className="relative h-44 rounded-3xl bg-white/35 p-4 backdrop-blur-sm">
        <div className="absolute inset-x-0 bottom-0 h-12 rounded-b-3xl bg-emerald-200/65" />
        {level === 1 && (
          <motion.div
            animate={{ x: [0, 220] }}
            transition={{ repeat: Infinity, duration: 8, ease: "linear" }}
            className="absolute left-6 top-8 text-2xl"
          >
            🕊️
          </motion.div>
        )}
        {level === 3 && (
          <motion.div
            animate={{ y: [0, 60], rotate: [0, 40] }}
            transition={{ repeat: Infinity, duration: 3 }}
            className="absolute left-16 top-12 text-xl"
          >
            🍂
          </motion.div>
        )}
        {level === 4 && (
          <>
            <motion.div
              animate={{ opacity: [0, 1, 0] }}
              transition={{ repeat: Infinity, duration: 1 }}
              className="absolute right-20 top-5 text-3xl"
            >
              ⚡
            </motion.div>
            <motion.div
              animate={{ y: [0, 80] }}
              transition={{ repeat: Infinity, duration: 1.2 }}
              className="absolute left-28 top-4 text-2xl"
            >
              🌧️
            </motion.div>
          </>
        )}
        <div className="absolute bottom-8 left-6 right-6 flex items-end justify-center gap-3">
          {buildings.map((height, idx) => (
            <motion.div
              key={`${level}-${idx}`}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.06 }}
              className={cn(
                "w-10 rounded-t-xl shadow-sm",
                height,
                level === 1
                  ? "bg-white/92"
                  : level === 2
                    ? "bg-slate-100/90"
                    : level === 3
                      ? "bg-stone-300/90"
                      : "bg-stone-500/80",
              )}
            >
              <div className="mx-auto mt-3 grid w-6 grid-cols-2 gap-1">
                {[0, 1, 2, 3].map((i) => (
                  <span key={i} className="h-2 rounded-sm bg-slate-400/50" />
                ))}
              </div>
            </motion.div>
          ))}
        </div>
      </div>

      <div className="mt-4 grid grid-cols-2 gap-3 text-xs text-slate-600">
        <div className="rounded-2xl bg-white/55 p-3">
          <p className="font-semibold text-slate-800">建筑图层</p>
          <p className="mt-1">{meta.town}</p>
        </div>
        <div className="rounded-2xl bg-white/55 p-3">
          <p className="font-semibold text-slate-800">天气动效</p>
          <p className="mt-1">{meta.weather}</p>
        </div>
      </div>
    </div>
  );
}

function HomePage({ stats, setPage, healthLevel, warning, totalBudget }) {
  const meta = healthMeta[healthLevel];
  return (
    <div className="pb-28">
      <PageHeader title="模拟城市记账本" subtitle="让每一笔消费都影响你的小镇命运" />
      <TownScene level={healthLevel} warning={warning} />

      <div className="mx-5 mt-5 grid grid-cols-2 gap-3">
        <StatCard icon={Wallet} label="今日支出" value={money(stats.today)} sub={`日均预算 ${money(stats.daily)}`} />
        <StatCard icon={Landmark} label="本月累计" value={money(stats.total)} sub={`合理线 ${money(stats.line)}`} />
        <StatCard icon={CheckCircle2} label="剩余预算" value={money(stats.remain)} sub={`月总预算 ${money(totalBudget)}`} />
        <StatCard icon={CloudSun} label="健康等级" value={meta.name} sub={meta.desc} />
      </div>

      <Card className="mx-5 mt-5">
        <CardContent className="p-5">
          <div className="flex items-start gap-3">
            <div className="rounded-2xl bg-amber-100 p-2">
              <AlertTriangle className="h-5 w-5 text-amber-700" />
            </div>
            <div>
              <p className="font-bold text-slate-900">状态说明</p>
              <p className="mt-1 text-sm leading-6 text-slate-500">
                {meta.desc} 系统会按照“破产 → 萧条 → 平稳 → 繁荣”的优先级重新计算小镇状态。
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      <div className="mx-5 mt-5 grid grid-cols-2 gap-3">
        <Button onClick={() => setPage("add")} className="h-14 rounded-2xl text-base shadow-sm">
          <PlusCircle className="h-5 w-5" />
          记一笔
        </Button>
        <Button onClick={() => setPage("budget")} variant="secondary" className="h-14 rounded-2xl text-base shadow-sm">
          <Settings className="h-5 w-5" />
          预算设置
        </Button>
      </div>
    </div>
  );
}

function AddBillPage({ onBack, onSave }) {
  const [type, setType] = useState("expense");
  const [amount, setAmount] = useState("600");
  const [categoryId, setCategoryId] = useState("entertainment");
  const [date, setDate] = useState(DEMO_DATE);
  const [remark, setRemark] = useState("游戏充值");

  return (
    <div className="pb-28">
      <PageHeader title="新增账单" subtitle="记录金额、类型、类别与日期" onBack={onBack} />
      <Card className="mx-5">
        <CardContent className="space-y-5 p-5">
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
            保存账单并刷新小镇
          </Button>
        </CardContent>
      </Card>
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

function BudgetPage({ totalBudget, setTotalBudget }) {
  const [draft, setDraft] = useState(String(totalBudget));

  return (
    <div className="pb-28">
      <PageHeader title="预算设置" subtitle="设置月总预算与可选分类预算" />
      <Card className="mx-5">
        <CardContent className="space-y-5 p-5">
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
              <span className="text-xs text-slate-400">原型示例为静态类别预算</span>
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
          <Button className="h-14 w-full rounded-2xl text-base" onClick={() => setTotalBudget(Number(draft || 0))}>
            保存预算配置
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}

function CategoryBoardPage({ bills }) {
  const expenseBills = bills.filter((bill) => bill.type === "expense");

  return (
    <div className="pb-28">
      <PageHeader title="分类看板" subtitle="查看各消费类别的预算消耗进度" />
      <div className="mx-5 space-y-3">
        {categories.map((cat) => {
          const Icon = cat.icon;
          const spent = expenseBills
            .filter((bill) => bill.categoryId === cat.id)
            .reduce((sum, bill) => sum + bill.amount, 0);
          const hasBudget = cat.budget > 0;
          const percent = hasBudget ? Math.round((spent / cat.budget) * 100) : 0;
          const status = !hasBudget ? "未设置预算" : percent > 100 ? "已超支" : percent >= 70 ? "接近上限" : "正常";

          return (
            <Card key={cat.id}>
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="rounded-2xl bg-slate-100 p-3">
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
                <div className="mt-4 h-3 overflow-hidden rounded-full bg-slate-100">
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
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}

function StatisticsPage({ stats, bills }) {
  const expense = bills.filter((bill) => bill.type === "expense");
  const income = bills.filter((bill) => bill.type === "income").reduce((sum, bill) => sum + bill.amount, 0);
  const ranked = categories
    .map((cat) => ({
      ...cat,
      spent: expense.filter((bill) => bill.categoryId === cat.id).reduce((sum, bill) => sum + bill.amount, 0),
    }))
    .sort((a, b) => b.spent - a.spent);
  const max = Math.max(...ranked.map((item) => item.spent), 1);

  return (
    <div className="pb-28">
      <PageHeader title="月度统计" subtitle="汇总收入、支出、剩余预算与分类占比" />
      <div className="mx-5 grid grid-cols-2 gap-3">
        <StatCard icon={BarChart3} label="本月总支出" value={money(stats.total)} sub="只统计支出" />
        <StatCard icon={Wallet} label="本月总收入" value={money(income)} sub="不抵扣健康度" />
        <StatCard icon={Sun} label="日均预算" value={money(stats.daily)} sub="月预算 / 月天数" />
        <StatCard icon={Landmark} label="合理消费线" value={money(stats.line)} sub={`当前第 ${DEMO_DAY} 天`} />
      </div>
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
    { id: "add", label: "记账", icon: PlusCircle },
    { id: "list", label: "明细", icon: ListChecks },
    { id: "board", label: "看板", icon: PieChart },
    { id: "stats", label: "统计", icon: BarChart3 },
  ];

  return (
    <div className="fixed bottom-4 left-1/2 z-50 w-[min(94%,460px)] -translate-x-1/2 rounded-[2rem] border border-white/70 bg-white/[0.88] p-2 shadow-[0_24px_70px_rgba(15,23,42,0.2)] backdrop-blur">
      <div className="grid grid-cols-5 gap-1">
        {items.map((item) => {
          const Icon = item.icon;
          const active = page === item.id;

          return (
            <button
              key={item.id}
              type="button"
              onClick={() => setPage(item.id)}
              className={cn(
                "rounded-2xl px-2 py-2 text-xs font-semibold transition",
                active ? "bg-slate-900 text-white" : "text-slate-500",
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
  const [editingBill, setEditingBill] = useState(null);
  const [warning, setWarning] = useState(false);
  const stats = useMemo(() => calculateHealth(totalBudget, bills), [totalBudget, bills]);

  useEffect(() => {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        bills,
        totalBudget,
      }),
    );
  }, [bills, totalBudget]);

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
    setPage("home");
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
            {page === "budget" && <BudgetPage totalBudget={totalBudget} setTotalBudget={updateBudget} />}
            {page === "board" && <CategoryBoardPage bills={bills} />}
            {page === "stats" && <StatisticsPage stats={stats} bills={bills} />}
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
