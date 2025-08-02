#!/bin/bash

echo "Введите название модуля (пример: vendor.module):"
read MODULE_NAME

if [ -z "$MODULE_NAME" ]; then
  echo "Название модуля не может быть пустым"
  exit 1
fi

BASE_DIR="$MODULE_NAME"

# Разделяем vendor и module
VENDOR=$(echo "$MODULE_NAME" | cut -d'.' -f1)
MODULE=$(echo "$MODULE_NAME" | cut -d'.' -f2)

if [ -z "$VENDOR" ] || [ -z "$MODULE" ]; then
  echo "Неверный формат названия модуля. Формат: vendor.module"
  exit 1
fi


# Создаём структуру
mkdir -p "$BASE_DIR/install/admin"
# mkdir -p "$BASE_DIR/install/admin/components/$VENDOR"
# mkdir -p "$BASE_DIR/install/admin/components/$VENDOR"
# mkdir -p "$BASE_DIR/install/admin/db/mysql"
mkdir -p "$BASE_DIR/lib"
mkdir -p "$BASE_DIR/lang/ru/install"
mkdir -p "$BASE_DIR/lang/ru/lib"
mkdir -p "$BASE_DIR/js"
mkdir -p "$BASE_DIR/admin"


# Создаём install/version.php
cat > "$BASE_DIR/install/version.php" <<'EOF'
<?php
$arModuleVersion = array(
    'VERSION' => '1.0.0',
    'VERSION_DATE' => date('Y-m-d H:i:s'),
);
EOF



# Создаём install/admin/${VENDOR}_${MODULE}_main.php
cat > "$BASE_DIR/install/admin/${VENDOR}_${MODULE}_main.php" <<EOF
<?php
require(\$_SERVER['DOCUMENT_ROOT'].'/local/modules/$BASE_DIR/admin/${VENDOR}_${MODULE}_main.php');
EOF


# Создаём /admin/${VENDOR}_${MODULE}_main.php
cat > "$BASE_DIR/admin/${VENDOR}_${MODULE}_main.php" <<EOF
<?php
use Bitrix\Main\Loader;
require_once(\$_SERVER['DOCUMENT_ROOT'].'/bitrix/modules/main/include/prolog_admin_before.php');
\$APPLICATION->SetTitle(("Модуль ${VENDOR}_${MODULE}_main"));
require(\$_SERVER["DOCUMENT_ROOT"]."/bitrix/modules/main/include/prolog_admin_after.php");
echo 'Главная страница модуля';
require(\$_SERVER['DOCUMENT_ROOT'].'/bitrix/modules/main/include/epilog_admin.php');
EOF


# Создаём /admin/menu.php
cat > "$BASE_DIR/admin/menu.php" <<EOF
<?php
if (\$USER->isAdmin()) {
    \$MODULE_ID = basename(dirname(__FILE__));

    \$aMenu = array(
        'parent_menu' => 'global_menu_services',
        'section' => '',
        'sort' => 700,
        'text' => 'Основной раздел text',
        'title' => 'Основной раздел title',
        'icon' => '',
        'page_icon' => '',
        'items_id' => \$MODULE_ID . '_items',
        'more_url' => array(),
        'items' => array(
            array(
                'text' => 'Подпункт text',
                'url' => "${VENDOR}_${MODULE}_main.php", // Разобраться zsh не понимает одинарные кавычки
                'title' => 'Подпункт title'
            )
        )
    );
    return \$aMenu;
}
return false;
EOF


# Создаём options.php
cat > "$BASE_DIR/options.php" <<EOF
<?php
IncludeModuleLangFile(__FILE__);
IncludeModuleLangFile(\$_SERVER['DOCUMENT_ROOT'].BX_ROOT.'/modules/main/options.php');
EOF



# Создаём include.php
cat > "$BASE_DIR/include.php" <<EOF
<?php
// Если namespase заданы правильно то регистрация
// автозагрузчика не нужна
// но с ним подключение проходит быстрее
defined('B_PROLOG_INCLUDED') and (B_PROLOG_INCLUDED === true) or die();
use Bitrix\Main\Loader;
Loader::registerAutoLoadClasses('${VENDOR}_${MODULE}', array(
    '${VENDOR}\${MODULE}\${VENDOR}${MODULE}Table' => 'lib/class.php',
));
EOF


# Создаём class.php
cat > "$BASE_DIR/lib/class.php" <<EOF
<?php
namespace ${VENDOR}\\${MODULE};
use Bitrix\Main;
class ${VENDOR}${MODULE}Table extends Main\Entity\DataManager
{
  // Ваш класс для автозагрузчика
}
EOF



# Создаём install/index.php
cat > "$BASE_DIR/install/index.php" <<EOF
<?php
use Bitrix\\Main\\Localization\\Loc;
Loc::loadMessages(__FILE__);
// Обработчик установки модуля
class ${VENDOR}_${MODULE} extends CModule
{
    var \$MODULE_ID = '$VENDOR.$MODULE';
    var \$MODULE_VERSION;
    var \$MODULE_VERSION_DATE;
    var \$MODULE_NAME;
    var \$MODULE_DESCRIPTION;
    var \$PARTNER_NAME;
    var \$PARTNER_URI;

    function __construct()
    {
        \$arModuleVersion = array();
        include(dirname(__FILE__).'/version.php');

        \$this->MODULE_VERSION = \$arModuleVersion['VERSION'];
        \$this->MODULE_VERSION_DATE = \$arModuleVersion['VERSION_DATE'];
        // название итд сгенерировано из названия модуля
        \$this->MODULE_NAME = '${VENDOR}_${MODULE}_MODULE_NAME';
        \$this->MODULE_DESCRIPTION = '${VENDOR}_${MODULE}_MODULE_DESC';
        \$this->PARTNER_NAME = '${VENDOR}_${MODULE}_PARTNER_NAME';
        \$this->PARTNER_URI = 'https://${VENDOR}_${MODULE}_PARTNER_URI';
    }


    function InstallDB(\$arParams = array())
    {
      // Установка БД
      global \$DB;
      //\$DB->RunSQLBatch(dirname(__FILE__).'/db/mysql/install.sql');
      return true;
    }

    function UnInstallDB(\$arParams = array())
    {
       // Удаление БД
       global \$DB;
       //\$DB->RunSQLBatch(dirname(__FILE__).'/db/mysql/uninstall.sql');
       return true;
    }


    /*
    function InstallEvents()
    {
        // Создание событий
        global \$DB;
        return true;
    }

    function UnInstallEvents()
    {
        // Удаление событий
        return true;
    }
    */

    // Копирование файлов
    function InstallFiles(\$arParams = array())
    {
        CopyDirFiles(dirname(__FILE__).'/admin', \$_SERVER['DOCUMENT_ROOT'].'/bitrix/admin', true, true);
        return true;
    }

    function UnInstallFiles()
    {
      DeleteDirFiles(dirname(__FILE__).'/admin', \$_SERVER['DOCUMENT_ROOT'].'/bitrix/admin');
      return true;
    }

    function DoInstall()
    {
        global \$APPLICATION;
        \$this->InstallFiles();
        RegisterModule(\$this->MODULE_ID);
       // \$this->InstallDB();
    }

    function DoUninstall()
    {
        global \$APPLICATION;
        \$this->UnInstallFiles();

        // Если ставили с базой, не забываем предложить сохранить таблицы
        UnRegisterModule(\$this->MODULE_ID);
        // \$this->UnInstallDB();
    }
}
EOF

echo "Структура модуля создана в ${BASE_DIR}"
