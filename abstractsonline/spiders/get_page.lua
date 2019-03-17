function main(splash)
    local wait_for_page_load_js = [[
            function main(splash) {
                document.addEventListener("load", function(){splash.resume()});
            }
        ]]

    local set_max_per_page = splash:jsfunc([[
        function() {
            document.querySelector(".results-per-page button:last-child").click()
        }
    ]])

    local expand_items_js = [[
        function main(splash) {
            list = document.querySelectorAll("#results li.result i.icon-caret-right");
            for (i=0;i<list.length;i++)
                setTimeout(
                    function(el, is_final){
                        el.click();
                        if (is_final)
                            splash.resume();
                    },
                    i*300, list[i], i==list.length-1
                )
        }
    ]]

    local has_next = splash:jsfunc([[
        function () {
            var next_btn = document.querySelector("#paginator li.next")
            return (next_btn && next_btn.getAttribute('class').indexOf('disabled')===-1)
        }
    ]])

    local click_next = splash:jsfunc([[
        function () {
            var next_btn = document.querySelector("#paginator li.next")
            if (next_btn && next_btn.getAttribute('class').indexOf('disabled')===-1) {
                next_btn.querySelector('span').click();
                return true;
            }
            else
                return false;
        }
    ]])



    if not splash.args.content then
        -- get page by request to url
        splash.images_enabled = false
        assert(splash:go(splash.args.url))
        assert(splash:wait(7))
--        set_max_per_page()
        assert(splash:wait(1))
    else
        --    below not work properly at current

        -- set already recieving page as current
        splash:init_cookies(splash.args.cookies)
        assert(splash:set_content(splash.args.content))
        click_next()
        assert(splash:wait(2))
        splash:set_viewport_full()
        return splash:png()
    end

--    splash:set_viewport_full()
    splash:wait_for_resume(expand_items_js, 60)
    splash:wait(2)

    return {
        html = splash:html(),
--  		png = splash:png(),
        cookies = splash:get_cookies(),
        has_next = has_next()
    }
end