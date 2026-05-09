<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="products.jsp" %>

<%
    // ==========================================
    // 處理加入購物車（PRG 模式防止重整重複送出）
    // ==========================================
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String idStr = request.getParameter("id");
        int pid      = parseId(idStr);
        String qtyStr = request.getParameter("qty");
        int qty = 1;
        try { qty = Math.max(1, Math.min(99, Integer.parseInt(qtyStr))); }
        catch (Exception e) { qty = 1; }

        if (getProduct(pid) != null) {
            // 購物車用 Map<productId, 數量> 儲存
            java.util.Map<Integer,Integer> cart =
                (java.util.Map<Integer,Integer>) session.getAttribute("cart");
            if (cart == null) cart = new java.util.LinkedHashMap<>();
            cart.merge(pid, qty, Integer::sum);
            session.setAttribute("cart", cart);
        }
        response.sendRedirect("now.jsp");
        return;
    }

    // 計算購物車總數量（顯示用）
    java.util.Map<Integer,Integer> cart =
        (java.util.Map<Integer,Integer>) session.getAttribute("cart");
    int cartTotal = 0;
    if (cart != null) for (int v : cart.values()) cartTotal += v;
    request.setAttribute("cartTotal", cartTotal);
    request.setAttribute("productList", PRODUCTS);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>質感選物 — 居家選品</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --sand:   #FDFBF7;
            --latte:  #D4C3B3;
            --mocha:  #A68A6D;
            --espresso: #8C735A;
            --text:   #3a3228;
        }
        * { box-sizing: border-box; }
        body { background: var(--sand); font-family: "微軟正黑體", sans-serif; color: var(--text); }

        /* ── Navbar ── */
        .navbar-custom { background: var(--latte); }
        .cart-badge {
            position: relative; display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 999px;
            background: rgba(255,255,255,.45); backdrop-filter: blur(4px);
            text-decoration: none; color: var(--text); font-weight: 600;
            transition: background .2s;
        }
        .cart-badge:hover { background: rgba(255,255,255,.7); color: var(--text); }
        .cart-badge .dot {
            position: absolute; top: 2px; right: 2px;
            min-width: 18px; height: 18px; border-radius: 999px;
            background: #e74c3c; color: #fff; font-size: .65rem;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; line-height: 1;
        }

        /* ── Hero ── */
        .hero {
            background: linear-gradient(135deg, rgba(0,0,0,.38), rgba(0,0,0,.22)),
                        url('https://picsum.photos/1400/500?random=10') center/cover no-repeat;
            min-height: 380px; display: flex; align-items: center; justify-content: center;
            color: #fff; text-align: center;
        }
        .hero h1 { font-size: clamp(1.8rem, 4vw, 3rem); letter-spacing: .06em; text-shadow: 0 2px 8px rgba(0,0,0,.4); }
        .hero p  { font-size: 1.05rem; opacity: .88; }

        /* ── Cards ── */
        .product-card {
            border: 1px solid #ede6dc; border-radius: 14px;
            overflow: hidden; background: #fff;
            transition: transform .28s ease, box-shadow .28s ease;
            display: flex; flex-direction: column; height: 100%;
        }
        .product-card:hover { transform: translateY(-7px); box-shadow: 0 18px 36px rgba(140,115,90,.14); }
        .product-card img { width: 100%; aspect-ratio: 1/1; object-fit: cover; display: block; }
        .card-body { padding: 1.1rem 1.2rem 1.3rem; display: flex; flex-direction: column; flex: 1; }
        .card-title { font-weight: 700; font-size: 1rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: .35rem; }
        .card-desc  { font-size: .82rem; color: #888; line-height: 1.55; flex: 1; }
        .card-price { font-size: 1.15rem; font-weight: 700; color: var(--espresso); margin: .65rem 0 .75rem; }

        /* ── Hot badge ── */
        .hot-badge {
            position: absolute; top: 10px; left: 10px; z-index: 2;
            background: #e74c3c; color: #fff;
            font-size: .72rem; font-weight: 700; padding: 3px 10px; border-radius: 999px;
            letter-spacing: .04em;
        }

        /* ── 數量控制器 ── */
        .qty-wrap { display: flex; align-items: center; gap: 0; border: 1px solid var(--latte); border-radius: 8px; overflow: hidden; width: fit-content; }
        .qty-btn  { background: #f5f0ea; border: none; width: 32px; height: 32px; font-size: 1rem; cursor: pointer; color: var(--espresso); transition: background .15s; }
        .qty-btn:hover  { background: var(--latte); }
        .qty-input { border: none; width: 38px; text-align: center; font-weight: 700; font-size: .9rem; background: #fff; outline: none; }

        /* ── Buttons ── */
        .btn-mocha { background: var(--mocha); color: #fff; border: none; border-radius: 8px; font-weight: 600; transition: background .2s; }
        .btn-mocha:hover { background: var(--espresso); color: #fff; }

        /* ── Section header ── */
        .section-title { font-size: 1.15rem; font-weight: 700; padding-bottom: .6rem; border-bottom: 2px solid var(--latte); margin-bottom: 1.5rem; }
    </style>
</head>
<body>

<!-- ── Navbar ── -->
<nav class="navbar navbar-expand-lg navbar-custom shadow-sm py-3 sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold fs-4" href="now.jsp" style="color: var(--text);">✨ 質感選物</a>
        <div class="ms-auto">
            <a href="cart.jsp" class="cart-badge">
                <i class="bi bi-bag2 fs-5"></i> 購物袋
                <c:if test="${cartTotal > 0}">
                    <span class="dot">${cartTotal}</span>
                </c:if>
            </a>
        </div>
    </div>
</nav>

<!-- ── Hero ── -->
<div class="hero mb-5">
    <div>
        <p class="mb-2" style="letter-spacing:.14em; font-size:.85rem; opacity:.8; text-transform:uppercase;">Spring Collection</p>
        <h1 class="fw-bold mb-3">春季居家煥新提案</h1>
        <p>每一件都是為了讓生活慢下來而存在</p>
    </div>
</div>

<!-- ── 商品列表 ── -->
<div class="container mb-5">
    <div class="section-title">所有商品</div>
    <div class="row row-cols-1 row-cols-sm-2 row-cols-lg-3 g-4">

        <c:forEach var="item" items="${productList}" varStatus="st">
        <div class="col">
            <div class="product-card shadow-sm position-relative">
                <c:if test="${item[4] == 'true'}">
                    <span class="hot-badge">🔥 熱銷</span>
                </c:if>
                <a href="detail.jsp?id=${st.index}">
                    <img src="${item[3]}"
                        alt="${item[0]}"
                        loading="lazy"
                        onerror="this.onerror=null; this.src='https://picsum.photos/seed/${st.index}/600/600';">
                </a>
                <div class="card-body">
                    <a href="detail.jsp?id=${st.index}" class="text-decoration-none text-dark">
                        <div class="card-title">${item[0]}</div>
                    </a>
                    <p class="card-desc">${item[1]}</p>
                    <div class="card-price">NT$ ${item[2]}</div>

                    <!-- 數量選擇 + 加入購物車 -->
                    <form action="now.jsp" method="get" class="d-flex align-items-center gap-2">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="id" value="${st.index}">
                        <div class="qty-wrap">
                            <button type="button" class="qty-btn" onclick="adjustQty(this,-1)">−</button>
                            <input type="number" name="qty" value="1" min="1" max="99" class="qty-input" readonly>
                            <button type="button" class="qty-btn" onclick="adjustQty(this,1)">＋</button>
                        </div>
                        <button type="submit" class="btn btn-mocha flex-fill py-2">加入購物袋</button>
                    </form>
                </div>
            </div>
        </div>
        </c:forEach>

    </div>
</div>

<script>
function adjustQty(btn, delta) {
    const input = btn.parentElement.querySelector('.qty-input');
    const val = Math.min(99, Math.max(1, parseInt(input.value) + delta));
    input.value = val;
}
</script>
</body>
</html>