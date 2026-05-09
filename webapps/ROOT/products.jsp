<%@ page contentType="text/html;charset=UTF-8" %>
<%!
    // ==========================================
    // 全域商品資料（唯一來源，所有頁面 include 此檔）
    // 欄位順序：[0]名稱 [1]描述 [2]價格 [3]圖片URL [4]是否熱銷
    // ==========================================
    static final String[][] PRODUCTS = {
        {"極簡風陶瓷咖啡杯", "職人手工捏製，溫潤手感。適合每日早晨的一杯黑咖啡，帶來寧靜的開始。", "580",   "https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=600&h=600&fit=crop", "false"},
        {"純棉亞麻室內拖鞋", "親膚透氣，居家必備。採用天然材質，吸汗乾爽，腳步輕盈無負擔。",     "350",   "https://images.unsplash.com/photo-1603487742131-4160ec999306?w=600&h=600&fit=crop", "false"},
        {"北歐風實木小茶几", "自然木紋，堅固耐用。適合放在沙發旁或床頭，放本書、一杯茶剛剛好。", "2,280", "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&h=600&fit=crop", "false"},
        {"手作大豆蠟燭",     "療癒香氛，放鬆身心。採用環保大豆蠟與天然精油，無黑煙，燃燒更持久。", "650",  "https://images.pexels.com/photos/3270223/pexels-photo-3270223.jpeg?w=600&h=600&fit=crop", "true"},
        {"日系水洗棉床包組", "裸睡等級，柔軟舒適。經過特殊水洗工藝，越洗越柔軟，給你一夜好眠。", "1,890", "https://images.unsplash.com/photo-1540518614846-7eded433c457?w=600&h=600&fit=crop", "false"},
        {"手沖咖啡濾杯壺組", "在家享受咖啡館時光。耐熱玻璃材質，刻度清晰，新手也能沖出好味道。", "990",  "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&h=600&fit=crop", "true"}
    };

    // 安全取得商品（防止陣列越界）
    static String[] getProduct(int id) {
        if (id < 0 || id >= PRODUCTS.length) return null;
        return PRODUCTS[id];
    }

    // 安全解析 id 參數
    static int parseId(String idStr) {
        try { return Integer.parseInt(idStr); }
        catch (Exception e) { return -1; }
    }

    // 購物車輔助：取得目前數量
    static int getCartCount(javax.servlet.http.HttpSession s) {
        Integer n = (Integer) s.getAttribute("cartCount");
        return n == null ? 0 : n;
    }
%>