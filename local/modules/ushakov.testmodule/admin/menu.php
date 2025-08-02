<?php
if ($USER->isAdmin()) {
    $MODULE_ID = basename(dirname(__FILE__));

    $aMenu = array(
        'parent_menu' => 'global_menu_services',
        'section' => '',
        'sort' => 700,
        'text' => 'Основной раздел text',
        'title' => 'Основной раздел title',
        'icon' => '',
        'page_icon' => '',
        'items_id' => $MODULE_ID . '_items',
        'more_url' => array(),
        'items' => array(
            array(
                'text' => 'Подпункт text',
                'url' => "ushakov_testmodule_main.php", // Разобраться zsh не понимает одинарные кавычки
                'title' => 'Подпункт title'
            )
        )
    );
    return $aMenu;
}
return false;
