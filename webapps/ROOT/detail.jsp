<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="products.jsp" %>

<%
    // ==========================================
    // 取得商品（安全防越界）
    // ==========================================
    int pid = parseId(request.getParameter("id"));
    String[] product = getProduct(pid);

    if (product == null) {
        response.sendRedirect("now.jsp");
        return;
    }
    request.setAttribute("product", product);
    request.setAttribute("pid", pid);

    // 購物車總數
    java.util.Map<Integer,Integer> cart =
        (java.util.Map<Integer,Integer>) session.getAttribute("cart");
    int cartTotal = 0;
    if (cart != null) for (int v : cart.values()) cartTotal += v;
    request.setAttribute("cartTotal", cartTotal);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${product[0]} — 質感選物</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --sand: #FDFBF7; --latte: #D4C3B3;
            --mocha: #A68A6D; --espresso: #8C735A; --text: #3a3228;
        }
        body { background: var(--sand); font-family: "微軟正黑體", sans-serif; color: var(--text); }
        .navbar-custom { background: var(--latte); }
        .cart-badge {
            position: relative; display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 999px;
            background: rgba(255,255,255,.45); backdrop-filter: blur(4px);
            text-decoration: none; color: var(--text); font-weight: 600; transition: background .2s;
        }
        .cart-badge:hover { background: rgba(255,255,255,.7); color: var(--text); }
        .cart-badge .dot {
            position: absolute; top: 2px; right: 2px;
            min-width: 18px; height: 18px; border-radius: 999px;
            background: #e74c3c; color: #fff; font-size: .65rem;
            display: flex; align-items: center; justify-content: center; font-weight: 700;
        }
        .product-img {
            border-radius: 16px; width: 100%;
            aspect-ratio: 1/1; object-fit: cover;
            box-shadow: 0 12px 32px rgba(140,115,90,.18);
        }
        .info-panel { padding: 0 0 0 2.5rem; }
        @media(max-width:767px) { .info-panel { padding: 1.5rem 0 0; } }
        .price { font-size: 1.8rem; font-weight: 800; color: var(--espresso); }
        .hot-badge { background: #e74c3c; color: #fff; font-size: .72rem; font-weight: 700; padding: 4px 12px; border-radius: 999px; }
        .qty-wrap { display: flex; align-items: center; border: 1.5px solid var(--latte); border-radius: 10px; overflow: hidden; width: fit-content; }
        .qty-btn  { background: #f5f0ea; border: none; width: 40px; height: 40px; font-size: 1.1rem; cursor: pointer; color: var(--espresso); transition: background .15s; }
        .qty-btn:hover { background: var(--latte); }
        .qty-input { border: none; width: 50px; text-align: center; font-weight: 700; font-size: 1rem; background: #fff; outline: none; }
        .btn-mocha { background: var(--mocha); color: #fff; border: none; border-radius: 10px; font-weight: 600; font-size: 1rem; transition: background .2s; }
        .btn-mocha:hover { background: var(--espresso); color: #fff; }
        .btn-outline-mocha { border: 2px solid var(--mocha); color: var(--mocha); border-radius: 10px; font-weight: 600; background: transparent; transition: all .2s; }
        .btn-outline-mocha:hover { background: var(--mocha); color: #fff; }
        .divider { border-top: 1px solid #ede6dc; }
    </style>
</head>
<body>

<!-- ── Navbar ── -->
<nav class="navbar navbar-expand-lg navbar-custom shadow-sm py-3 sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold fs-4" href="now.jsp" style="color:var(--text);">✨ 質感選物</a>
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

<div class="container my-5">
    <!-- 麵包屑 -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb" style="font-size:.85rem;">
            <li class="breadcrumb-item"><a href="now.jsp" class="text-decoration-none" style="color:var(--mocha);">所有商品</a></li>
            <li class="breadcrumb-item active">${product[0]}</li>
        </ol>
    </nav>

    <div class="row align-items-center bg-white rounded-4 shadow-sm p-4 p-md-5" style="border: 1px solid #ede6dc;">
        <!-- 商品圖 -->
        <div class="col-md-6">
            <img src="${product[3]}" class="product-img" alt="${product[0]}">
        </div>

        <!-- 商品資訊 -->
        <div class="col-md-6 info-panel">
            <c:if test="${product[4] == 'true'}">
                <span class="hot-badge mb-3 d-inline-block">🔥 熱銷商品</span>
            </c:if>

            <h2 class="fw-bold mb-3">${product[0]}</h2>
            <p class="text-muted lh-lg mb-4">${product[1]}</p>
            <div class="price mb-4">NT$ ${product[2]}</div>

            <div class="divider mb-4"></div>

            <!-- 數量 + 按鈕 -->
            <form action="now.jsp" method="get">
                <input type="hidden" name="action" value="add">
                <input type="hidden" name="id" value="${pid}">

                <label class="fw-bold mb-2 d-block" style="font-size:.9rem;">數量</label>
                <div class="d-flex align-items-center gap-3 mb-4">
                    <div class="qty-wrap">
                        <button type="button" class="qty-btn" onclick="adjustQty(this,-1)">−</button>
                        <input type="number" name="qty" value="1" min="1" max="99" class="qty-input" readonly>
                        <button type="button" class="qty-btn" onclick="adjustQty(this,1)">＋</button>
                    </div>
                </div>

                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-mocha btn-lg py-3">
                        <i class="bi bi-bag-plus me-2"></i>加入購物袋
                    </button>
                    <a href="now.jsp" class="btn btn-outline-mocha btn-lg py-2">
                        <i class="bi bi-arrow-left me-1"></i>繼續選購
                    </a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function adjustQty(btn, delta) {
    const input = btn.parentElement.querySelector('.qty-input');
    input.value = Math.min(99, Math.max(1, parseInt(input.value) + delta));
}
</script>
</body>
</html>