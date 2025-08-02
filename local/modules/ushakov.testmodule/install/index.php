<?php
use Bitrix\Main\Localization\Loc;
Loc::loadMessages(__FILE__);
// Обработчик установки модуля
class ushakov_testmodule extends CModule
{
    var $MODULE_ID = 'ushakov.testmodule';
    var $MODULE_VERSION;
    var $MODULE_VERSION_DATE;
    var $MODULE_NAME;
    var $MODULE_DESCRIPTION;
    var $PARTNER_NAME;
    var $PARTNER_URI;

    function __construct()
    {
        $arModuleVersion = array();
        include(dirname(__FILE__).'/version.php');

        $this->MODULE_VERSION = $arModuleVersion['VERSION'];
        $this->MODULE_VERSION_DATE = $arModuleVersion['VERSION_DATE'];
        // название итд сгенерировано из названия модуля
        $this->MODULE_NAME = 'ushakov_testmodule_MODULE_NAME';
        $this->MODULE_DESCRIPTION = 'ushakov_testmodule_MODULE_DESC';
        $this->PARTNER_NAME = 'ushakov_testmodule_PARTNER_NAME';
        $this->PARTNER_URI = 'https://ushakov_testmodule_PARTNER_URI';
    }


    function InstallDB($arParams = array())
    {
      // Установка БД
      global $DB;
      //$DB->RunSQLBatch(dirname(__FILE__).'/db/mysql/install.sql');
      return true;
    }

    function UnInstallDB($arParams = array())
    {
       // Удаление БД
       global $DB;
       //$DB->RunSQLBatch(dirname(__FILE__).'/db/mysql/uninstall.sql');
       return true;
    }


    /*
    function InstallEvents()
    {
        // Создание событий
        global $DB;
        return true;
    }

    function UnInstallEvents()
    {
        // Удаление событий
        return true;
    }
    */

    // Копирование файлов
    function InstallFiles($arParams = array())
    {
        CopyDirFiles(dirname(__FILE__).'/admin', $_SERVER['DOCUMENT_ROOT'].'/bitrix/admin', true, true);
        return true;
    }

    function UnInstallFiles()
    {
      DeleteDirFiles(dirname(__FILE__).'/admin', $_SERVER['DOCUMENT_ROOT'].'/bitrix/admin');
      return true;
    }

    function DoInstall()
    {
        global $APPLICATION;
        $this->InstallFiles();
        RegisterModule($this->MODULE_ID);
       // $this->InstallDB();
    }

    function DoUninstall()
    {
        global $APPLICATION;
        $this->UnInstallFiles();

        // Если ставили с базой, не забываем предложить сохранить таблицы
        UnRegisterModule($this->MODULE_ID);
        // $this->UnInstallDB();
    }
}
