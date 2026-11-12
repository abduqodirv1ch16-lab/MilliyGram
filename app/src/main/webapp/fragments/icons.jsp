<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- MilliyGram belgisi: o'zbek milliy do'ppisi (chorsi do'ppi), yon-yuqoridan ko'rinishda.
     Ishlatilishi: <span class="logo-mark"><jsp:include page="/fragments/icons.jsp"/></span> --%>
<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg" class="logo-svg" aria-hidden="true">
    <defs>
        <linearGradient id="dpTop" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#a78bfa"/><stop offset="1" stop-color="#d946ef"/>
        </linearGradient>
        <linearGradient id="dpL" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#3b0f8c"/><stop offset="1" stop-color="#1e1b4b"/>
        </linearGradient>
        <linearGradient id="dpR" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stop-color="#6d28d9"/><stop offset="1" stop-color="#312e81"/>
        </linearGradient>
    </defs>
    <ellipse cx="24" cy="43" rx="15" ry="2.6" fill="#000" opacity=".16"/>
    <!-- chap va o'ng yoqlar -->
    <path d="M9 17 L24 23 L24 40 L5 33 Z" fill="url(#dpL)"/>
    <path d="M39 17 L24 23 L24 40 L43 33 Z" fill="url(#dpR)"/>
    <!-- tepa yuza -->
    <path d="M24 8 L39 17 L24 23 L9 17 Z" fill="url(#dpTop)"/>
    <path d="M9 17 L24 23 L39 17" fill="none" stroke="#fff" stroke-opacity=".55" stroke-width=".8" stroke-linejoin="round"/>
    <path d="M24 23 L24 40" stroke="#fff" stroke-opacity=".22" stroke-width=".8"/>
    <!-- tepadagi kashta -->
    <path d="M24 12.6 L28.6 15.6 L24 18.6 L19.4 15.6 Z" fill="#fff" fill-opacity=".92"/>
    <circle cx="24" cy="15.6" r="1.1" fill="#FF3366"/>
    <!-- bodom naqshlari -->
    <path d="M14.6 21.4 C18.6 25 18.4 31.4 14.2 36 C10.6 31.8 10.6 25.2 14.6 21.4 Z" fill="#fff" fill-opacity=".94"/>
    <path d="M14.5 25.2 C16 27.4 15.9 30.4 14.3 32.4 C12.8 30.4 12.8 27.4 14.5 25.2 Z" fill="#FF3366"/>
    <path d="M33.4 21.4 C29.4 25 29.6 31.4 33.8 36 C37.4 31.8 37.4 25.2 33.4 21.4 Z" fill="#fff" fill-opacity=".94"/>
    <path d="M33.5 25.2 C32 27.4 32.1 30.4 33.7 32.4 C35.2 30.4 35.2 27.4 33.5 25.2 Z" fill="#FF3366"/>
    <!-- pastki hoshiya -->
    <path d="M5 33 L24 40 L43 33" fill="none" stroke="#FF3366" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M6 30.6 L24 37.3 L42 30.6" fill="none" stroke="#fff" stroke-opacity=".7" stroke-width=".7" stroke-dasharray="1.5 1.5"/>
</svg>
