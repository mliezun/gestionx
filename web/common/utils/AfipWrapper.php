<?php

namespace common\utils;

use afipsdk;

class AfipWrapper
{
    private $tmp_cert;
    private $tmp_key;
    public $afip;

    public function __construct($cuit, $cert, $key, $production = false)
    {
        $this->tmp_cert = tmpfile();
        $meta_data = stream_get_meta_data($this->tmp_cert);
        $tmp_cert_path = $meta_data["uri"];

        $this->tmp_key = tmpfile();
        $meta_data = stream_get_meta_data($this->tmp_key);
        $tmp_key_path = $meta_data["uri"];

        if (dirname($tmp_key_path) != dirname($tmp_cert_path)) {
            throw new HTTPException(500, "Error en la generación de certificados de AFIP");
        }

        fwrite($this->tmp_cert, $cert);
        fwrite($this->tmp_key, $key);

        $tmp_folder = dirname($tmp_key_path) . '/';
        $tmp_cert_file = basename($tmp_cert_path);
        $tmp_key_file = basename($tmp_key_path);

        $this->afip = new \Afip([
            'CUIT' => $cuit,
            'cert' => $tmp_cert_file,
            'key' => $tmp_key_file,
            'res_folder' => $tmp_folder,
            'ta_folder' => '/var/www/certs/',
            'production' => $production
        ]);
    }

    public function __destruct()
    {
        // Borra los archivos temporales
        fclose($this->tmp_cert);
        fclose($this->tmp_key);
    }
}
