input_json = {
    "tipo_cbte": 201,
    "punto_vta": 4000,
    "fecha": "20190711",
    "concepto": 3,
    "tipo_doc": 80,
    "nro_doc": "30000000007",
    "cbte_nro": 12345678,
    "imp_total": "127.00",
    "imp_tot_conc": "3.00",
    "imp_neto": "100.00",
    "imp_iva": "21.00",
    "imp_trib": "1.00",
    "imp_op_ex": "2.00",
    "imp_subtotal": "105.00",
    "fecha_cbte": "20190711",
    "fecha_venc_pago": "20190711",
    "fecha_serv_desde": "20190711",
    "fecha_serv_hasta": "20190711",
    "moneda_id": "PES",
    "moneda_ctz": 1,
    "idioma_cbte": 1,
    "nombre_cliente": "Joao Da Silva",
    "domicilio_cliente": "Rua 76 km 34.5 Alagoas",
    "pais_dst_cmp": 200,
    "id_impositivo": "PJ54482221-l",
    "forma_pago": "30 dias",
    "obs_generales": "Observaciones Generales<br/>linea2<br/>linea3",
    "obs_comerciales": "Observaciones Comerciales<br/>texto libre",
    "motivo_obs": "Factura individual, DocTipo: 80, DocNro 30000000007 no se encuentra registrado en los padrones de AFIP.",
    "cae": "61123022925855",
    "fch_venc_cae": "20110320",
    "localidad_cliente": "Hurlingham",
    "provincia_cliente": "Buenos Aires",
    "subtotales_iva": [
        {
            "iva_id": 5,
            "base_imp": 100,
            "importe": 21
        }
    ],
    "items": [
        {
            "u_mtx": 123456,
            "cod_mtx": 1234567890123,
            "codigo": "P0001",
            "ds": "Descripcion del producto P0001\nLorem ipsum sit amet ",
            "qty": 1.00,
            "umed": 7,
            "precio": 110.00,
            "imp_iva": 23.10,
            "despacho": "Nº 123456",
            "dato_a": "Dato A"
        }
    ],
    "custom-nro-cli": "Cod.123",
    "custom-pedido": "1234",
    "custom-remito": "12345",
    "custom-transporte": "Camiones Ej.",
    "conf_pdf": {
        "EMPRESA": "GestionX",
        "CUIT": "CUIT 2039574773",
        "IVA": "IVA Responsable Inscripto"
    }
}

"""
fetch("http://0.0.0.0:5000/api/v1/pdf", {method:"POST", body: JSON.stringify(input_json), mode: "no-cors", headers: {"Content-Type": "application/json"}}).then(resp => resp.blob()).then(blob => {
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.style.display = "none";
    a.href = url;
    // the filename you want
    a.download = "salida.pdf";
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
    alert("your file has downloaded!"); // or you know, something with better UX...
})
"""