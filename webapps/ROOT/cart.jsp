<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ include file="products.jsp" %>

<%
    // ==========================================
    // 購物車操作（remove / clear / update）
    // ==========================================
    java.util.Map<Integer,Integer> cart =
        (java.util.Map<Integer,Integer>) session.getAttribute("cart");
    if (cart == null) { cart = new java.util.LinkedHashMap<>(); session.setAttribute("cart", cart); }

    String action = request.getParameter("action");

    if ("remove".equals(action)) {
        int pid = parseId(request.getParameter("id"));
        cart.remove(pid);
        response.sendRedirect("cart.jsp"); return;
    }
    if ("clear".equals(action)) {
        cart.clear();
        response.sendRedirect("cart.jsp"); return;
    }
    if ("update".equals(action)) {
        // 更新全部數量（表單批次送出）
        String[] ids  = request.getParameterValues("pid");
        String[] qtys = request.getParameterValues("qty");
        if (ids != null && qtys != null) {
            for (int i = 0; i < ids.length && i < qtys.length; i++) {
                int pid = parseId(ids[i]);
                int qty; try { qty = Integer.parseInt(qtys[i]); } catch(Exception e){ qty=1; }
                if (qty <= 0) { cart.remove(pid); }
                else { if (cart.containsKey(pid)) cart.put(pid, Math.min(99, qty)); }
            }
        }
        response.sendRedirect("cart.jsp"); return;
    }

    // 計算小計、總計
    int cartTotal = 0;
    int grandTotal = 0;
    java.util.List<Object[]> cartItems = new java.util.ArrayList<>();
    for (java.util.Map.Entry<Integer,Integer> entry : cart.entrySet()) {
        int pid = entry.getKey();
        int qty = entry.getValue();
        String[] p = getProduct(pid);
        if (p == null) continue;
        int price = Integer.parseInt(p[2].replace(",", ""));
        int subtotal = price * qty;
        cartTotal += qty;
        grandTotal += subtotal;
        cartItems.add(new Object[]{pid, p, qty, subtotal});
    }
    request.setAttribute("cartItems", cartItems);
    request.setAttribute("cartTotal", cartTotal);
    request.setAttribute("grandTotal", grandTotal);
%>

<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>購物袋 — 質感選物</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root { --sand:#FDFBF7; --latte:#D4C3B3; --mocha:#A68A6D; --espresso:#8C735A; --text:#3a3228; }
        body { background: var(--sand); font-family:"微軟正黑體",sans-serif; color:var(--text); }
        .navbar-custom { background: var(--latte); }
        .cart-badge {
            position:relative; display:inline-flex; align-items:center; gap:6px;
            padding:6px 14px; border-radius:999px;
            background:rgba(255,255,255,.45); backdrop-filter:blur(4px);
            text-decoration:none; color:var(--text); font-weight:600; transition:background .2s;
        }
        .cart-badge:hover { background:rgba(255,255,255,.7); color:var(--text); }
        .cart-badge .dot {
            position:absolute; top:2px; right:2px;
            min-width:18px; height:18px; border-radius:999px;
            background:#e74c3c; color:#fff; font-size:.65rem;
            display:flex; align-items:center; justify-content:center; font-weight:700;
        }
        .cart-table th { font-size:.82rem; color:#999; font-weight:600; text-transform:uppercase; letter-spacing:.04em; }
        .cart-table td { vertical-align:middle; border-color:#f0eae1; }
        .cart-table thead th { border-color:#f0eae1; }
        .item-img { width:72px; height:72px; object-fit:cover; border-radius:10px; }
        .qty-wrap { display:flex; align-items:center; border:1.5px solid var(--latte); border-radius:8px; overflow:hidden; }
        .qty-btn  { background:#f5f0ea; border:none; width:34px; height:34px; font-size:1rem; cursor:pointer; color:var(--espresso); }
        .qty-btn:hover { background:var(--latte); }
        .qty-input { border:none; width:42px; text-align:center; font-weight:700; font-size:.9rem; background:#fff; outline:none; }
        .btn-remove { background:none; border:none; color:#ccc; font-size:1.2rem; cursor:pointer; transition:color .15s; }
        .btn-remove:hover { color:#e74c3c; }
        .summary-box { background:#fff; border:1px solid #ede6dc; border-radius:14px; padding:1.5rem; }
        .btn-mocha { background:var(--mocha); color:#fff; border:none; border-radius:10px; font-weight:600; transition:background .2s; }
        .btn-mocha:hover { background:var(--espresso); color:#fff; }
        .btn-outline-mocha { border:2px solid var(--mocha); color:var(--mocha); border-radius:10px; font-weight:600; background:transparent; transition:all .2s; }
        .btn-outline-mocha:hover { background:var(--mocha); color:#fff; }
        .empty-state { text-align:center; padding:5rem 1rem; }
        .empty-state i { font-size:4rem; color:var(--latte); }
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
    <h4 class="fw-bold mb-4">購物袋 <span class="text-muted fw-normal fs-6">（共 ${cartTotal} 件）</span></h4>

    <c:choose>
    <%-- ── 空購物車 ── --%>
    <c:when test="${empty cartItems}">
        <div class="empty-state">
            <i class="bi bi-bag2 mb-4 d-block"></i>
            <h5 class="fw-bold mb-2">購物袋是空的</h5>
            <p class="text-muted mb-4">快去挑幾件讓生活更有質感的好物吧！</p>
            <a href="now.jsp" class="btn btn-mocha px-4 py-2">去逛逛</a>
        </div>
    </c:when>

    <%-- ── 有商品 ── --%>
    <c:otherwise>
    <form action="cart.jsp" method="get">
        <input type="hidden" name="action" value="update">
    <div class="row g-4">
        <!-- 商品清單 -->
        <div class="col-lg-8">
            <div class="bg-white rounded-4 shadow-sm p-3 p-md-4" style="border:1px solid #ede6dc;">
                <table class="table cart-table mb-0">
                    <thead>
                        <tr>
                            <th colspan="2">商品</th>
                            <th class="text-center">數量</th>
                            <th class="text-end">小計</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="row" items="${cartItems}">
                        <%-- row: [0]=pid [1]=product[] [2]=qty [3]=subtotal --%>
                        <tr>
                            <td style="width:90px;">
                                <img src="${row[1][3]}"
                                     class="item-img" alt="${row[1][0]}">
                            </td>
                            <td>
                                <a href="detail.jsp?id=${row[0]}" class="text-decoration-none fw-bold text-dark d-block">${row[1][0]}</a>
                                <small class="text-muted">NT$ ${row[1][2]}</small>
                                <input type="hidden" name="pid" value="${row[0]}">
                            </td>
                            <td class="text-center">
                                <div class="qty-wrap mx-auto" style="width:fit-content;">
                                    <button type="button" class="qty-btn" onclick="adjustQty(this,-1)">−</button>
                                    <input type="number" name="qty" value="${row[2]}" min="1" max="99" class="qty-input">
                                    <button type="button" class="qty-btn" onclick="adjustQty(this,1)">＋</button>
                                </div>
                            </td>
                            <td class="text-end fw-bold" style="color:var(--espresso);">
                                NT$ <span class="subtotal-cell">${row[3]}</span>
                            </td>
                            <td class="text-center">
                                <a href="cart.jsp?action=remove&id=${row[0]}" class="btn-remove" title="移除">
                                    <i class="bi bi-x-lg"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

            <div class="d-flex justify-content-between mt-3">
                <a href="now.jsp" class="btn btn-outline-mocha px-3 py-2">
                    <i class="bi bi-arrow-left me-1"></i>繼續選購
                </a>
                <div class="d-flex gap-2">
                    <a href="cart.jsp?action=clear" class="btn btn-outline-danger px-3 py-2" onclick="return confirm('確定清空購物袋？')">
                        <i class="bi bi-trash me-1"></i>清空
                    </a>
                    <button type="submit" class="btn btn-mocha px-3 py-2">更新數量</button>
                </div>
            </div>
        </div>

        <!-- 訂單摘要 -->
        <div class="col-lg-4">
            <div class="summary-box">
                <h6 class="fw-bold mb-3">訂單摘要</h6>
                <div class="d-flex justify-content-between mb-2 text-muted small">
                    <span>商品總計（${cartTotal} 件）</span>
                    <span>NT$ ${grandTotal}</span>
                </div>
                <div class="d-flex justify-content-between mb-2 text-muted small">
                    <span>運費</span>
                    <span class="text-success">免運</span>
                </div>
                <hr style="border-color:#ede6dc;">
                <div class="d-flex justify-content-between fw-bold fs-5 mb-4">
                    <span>總金額</span>
                    <span style="color:var(--espresso);">NT$ ${grandTotal}</span>
                </div>
                <button type="button" class="btn btn-mocha w-100 py-3 fw-bold fs-6" onclick="alert('結帳功能尚未開放，感謝您的惠顧！')">
                    前往結帳 <i class="bi bi-arrow-right ms-1"></i>
                </button>
            </div>
        </div>
    </div>
    </form>
    </c:otherwise>
    </c:choose>
</div>

<script>
function adjustQty(btn, delta) {
    const input = btn.parentElement.querySelector('.qty-input');
    input.value = Math.min(99, Math.max(1, parseInt(input.value) + delta));
}
</script>
</body>
</html>