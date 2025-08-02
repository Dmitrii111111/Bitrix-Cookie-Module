<?php
// Если namespase заданы правильно то регистрация
// автозагрузчика не нужна
// но с ним подключение проходит быстрее
defined('B_PROLOG_INCLUDED') and (B_PROLOG_INCLUDED === true) or die();
use Bitrix\Main\Loader;
Loader::registerAutoLoadClasses('ushakov_testmodule', array(
    'ushakov${MODULE}${VENDOR}testmoduleTable' => 'lib/class.php',
));
