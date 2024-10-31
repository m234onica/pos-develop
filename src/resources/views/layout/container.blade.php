<!DOCTYPE HTML>
<Html lang="zh-Hant-TW">

<head>

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>

    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>

    @include('layout.css')
</head>

<body>
    <div class="container-fluid">
        <div class="tab">
            <div class="nev-tab">
                <button class="{{ Request::is('menu') ? 'active' : '' }}" id="menu" onclick="window.location.href='/menu'">菜單管理</button>
                <button class="{{ Request::is('order') || Request::is('order/create') ? 'active' : '' }}"
                    id="order" onclick="window.location.href='/order'">訂單管理</button>
            </div>
            @yield('content')
        </div>
    </div>
</body>

</Html>