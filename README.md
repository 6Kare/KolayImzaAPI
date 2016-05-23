
# Kolay Imza Geliştirici Dokümantasyonu

## Kolay İmza Nasıl Çalışır ?

Kolay imza **"sign:...."** adresi ile başlayan bir protokol kullanır. Bu adresi ister web uygulamanız içerisinde isterseniz de desktop uygulama içerisinden çağırarak kolay imzayı başlatabilirsiniz. Sign adresi içerisine imza atılacak belge ve bilgilere ait talebin bilgileri yer alır. Bununla ilgili bilgiler aşağıda detaylı olarak anlatılacaktır ama önce kolay imzayı nasıl başlatacağımıza bakalım.

Web uygulaması içerisinde kolay imzanın başlatılması. HTML içerisinde aşağıdakine benzer bir şekilde bir link yerleştirmeniz yeterlidir.

```
<a href="sign:XXXX">İmzala</a> 
```

## Nasıl Çalışır ?

```sequence
Note over Uygulama: İmza talebi oluşturulur.
Uygulama->Kolay İmza: İmza talebi sign adresi ile kolay imza'ya gönderilir.
Note right of Kolay İmza: İmza isteği incelenir.
Kolay İmza-->Uygulama: Gerekiyorsa imzalanacak belgeler ağ üzerinden indirilir.
Note over Kolay İmza: İmzalama işlemi tamamlanır.
Kolay İmza-->Uygulama: İsteniyorsa imza içeriği gönderilir. 
Kolay İmza-->Uygulama: İsteniyor ise toplu imza cevabı gönderilir.
```

## Canlı Kullanım

Örnek canlı kullanımını [buraya tıklayarak](file.php) deneyebilirsiniz.  Bu örneğe ait kaynak kod bu sayfanın devamında verilmiştir.

## İmza Talebi İsteği Oluşturulur ?

İmza talebine ait bilgileri 2 farklı şekilde Kolay İmza'ya gönderebilirsiniz.

Sign içerisinde imza talebini geri dönecek adresi verebilirsiniz. JSON cevabı gönderecek olan adresi **?xs=&lt;adres&gt;** şeklinde belirtmektir.

```
<a href="sign://?xs=http://localhost/app/file.aspx?id=123&op=request">İmzala</a>
```

Bu örnekte file.aspx dosyasının aşağıdakine benzer bir **Request** tipinde bir JSON geri göndermesi beklenir.

```
{
    "resources" : [
        {
            "source" : "http://localhost/app/file.aspx?id=123"
        }
    ],
    "responseUrl" : "http://localhost/app/file.aspx?id=123&op=response"
}
```

> **resources** içerisinde imzalanmasını istediğiniz kaynaklara ait bilgiler yer alır. Birden fazla kaynak belirterek aynı anda birden fazla belgenin imzalanmasını sağlayabilirsiniz. Belge içeriğini örnekte olduğu gibi bir adres vererek veya base64 kodlu şekilde JSON içerisinde gönderebilirsiniz.

Alternatif olarak Request JSON objesini base64 kodlayarak adres içerisinde de gönderebilirsiniz.

```
<a href="sign://?xsjson=eyJyZXNvdXJjZXMiOlt7InNvdXJjZSI6Imh0dHA6Ly9sb2NhbGhvc3QvYXBwL2ZpbGUuYXNweD9pZD0xMjMifV0sInJlc3BvbnNlVXJsIjoiaHR0cDovL2xvY2FsaG9zdC9hcHAvZmlsZS5hc3B4P2lkPTEyMyZvcD1yZXNwb25zZSJ9">İmzala</a>
```

Bu yöntemi tercih ederseniz aşağıdaki gibi bir java script kodu ile adresi üretebilirsiniz.

```
$(document).ready(function() {
    var link = btoa(JSON.stringify({
        "resources" : [
            {
                "source" : "http://localhost/app/file.aspx?id=123"
            }
        ],
        "responseUrl" : "http://localhost/app/file.aspx?id=123&op=response"
    }));    
    // $('a.imzala').attr('src', link);
}
```

> Bir çok internet gezgininde **btoa** fonksiyonu türkçe karakterler ile ilgili problem çıkardığı için gerekiyor ise alternatif bir [base64 çevirici](http://www.webtoolkit.info/javascript-base64.html) kullanmanızı öneririz.

## İmza Geri Nasıl Alınır

İmza talebi oluşturulurken aşağıdaki örnekte olduğu gibi resource objesi üzerinde **targetUrl** belirttiyseniz imzalı bilgi yada belge standart dosya upload yöntemine benzer şekilde POST yöntemi ile belirttiğiniz adrese gönderilecektir. Bu adresin imzalı bilgiyi veri tabanına kaydetmesi beklenir.

```
{
    "resources" : [
        {
            "source" : "http://localhost/app/file.aspx?id=123",
            "targetUrl" : "http://localhost/app/file.aspx?id=123"
        }
    ]
}
```

Bunun dışında imza talebi içerisinde **responseUrl** belirtilmiş ise tüm imza detayları bu adrese JSON formatında aşağıdaki şekilde gönderilecektir.
    
```
{
    "certificate": "MIIG+zCCBe....BYsjR1L384",
    "certificateIssuer": "Nitelikli Elektronik Sertifika Hizmetleri",
    "certificateName": "SELAHATTİN BOSTANCI",
    "certificateSerialNumber": "4.......2",
    "createdAt": "2016-02-10T14:19:19.5071679+03:00",
    "resources": [
        {
            "attachSource": true,
            "digest": "Sha256",
            "signature": "MIAGCSqGSI....AAAAAA",
            "source": "http://localhost/app/file.aspx?id=123",
        }
    ]
}
```

> Request objesi üzerindeki **responseUrl** ve Resource üzerindeki **targetUrl** adreslerinin her ikisi de zorunlu değildir. İkisini de aynı anda kullanabilir veya herhangi birisini belirleyebilirsiniz. İkisi de belirtilmediğinde imza oluşturulur ancak gönderim yapılacak bir yer olmayacağından uygulama otomatik kapanacaktır.

## JSON Modelleri

### Resource
Bilgi veya belgeye ait kaynak bilgilerini belirtir.

**id: string**
: Kaynağa ait tekil bilgi. Zorunlu değildir, yanlızca kaynakları bir id numarası ile ayırt etmek için kullanılır.

**source: string**
: Kaynağın bulunduğu adres veya base64 kodlu bilgi yada metin. Bu alan içeriğine göre sourceType alanını belirlemeniz gereklidir.

**sourceType: string ∈ { Binary, PlainText, Url }**
: source alanının içeriğinin tipi

**sourceName: string**
: Kaynağın ekranda gösterilecek dosya adı. Zorunlu değildir.

**format: string ∈ { CadesBes, CadesT, CadesX, CadesA, PadesBes, PadesT, SMime }**
: Üretilecek imzanın biçimi. Belirtilmediğinde CadesBes kullanılır.

**digest: string ∈ { Sha1, Sha256, Sha384, Sha512 }**
: Kullanılacak özet algoritması.

**attachSource: boolean**
: Belge veya bilgi içeriği imza içerisine eklenmeli mi ?

**signature: string**
: Eğer kaynak imzalanmış ise Base64 kodlanmış imza içeriğini gösterir.

**targetUrl: string**
: İmza oluşturulduktan sonra imzanın POST metodu ile gönderileceği adres. Belirtilmediğinde gönderim yapılmaz.

**pdfOptions: object**
: PDF dosyaları için yerleştirilecek imza görüntüsünün özelliklerini belirler. Belirtilmediğinde imza kutusu görünür olmayacaktır.

: **signatureName: string**
: PDF içerisinde görüntülenecek imza adı.

: **reason: string**
: İmza nedeni

: **location: string**
: İmzanın atıldığı yer.

: **x: integer**
: İmza kutusunun yerleştirileceği X pozisyonu.

: **y: integer**
: İmza kutusunun yerleştirileceği Y pozisyonu.

: **width: integer**
: İmza kutusunun genişliği.

: **height: integer**
: İmza kutusunun yüksekliği.


### Request
İmza talebine ait bilgileri içerir. 

**id: string**
: Yapılan istek için belirlenecek tekil numara.

**resources: Resource[]**
: İmzalanması istenen kaynakların listesi.

**commonName: string**
: Kullanılacak sertifika sahibinin adı.

**timestamp: object**
: Zaman damgası kullanılacak ise erişim bilgilerini içerir. Belirtilmediğinde kullanıcı seçeneklerinde belirtilen zaman damgası kullanılacaktır.

**url: string**
: Zaman damgası sunucusunun adresi.

**user: string**
: Zaman damgası sunucusuna gönderilecek kullanıcı adı.

**password: string**
: Zaman damngası sunucusuna gönderilecek kullanıcının şifresi.

**createdAt: string (dateTime)**
: İmza talebinin oluşturulduğu tarih ve saat.

**responseUrl: string**
: İmza oluşturulduğunda cevabın geri gönderileceği adres.

### Response
İmza oluşturulduktan sonra gönderilen cevap bilgilerini içerir. 

**id: string**
: Yapılan isteğe ait tekil numara.

**resources: Resource[]**
: İmzalanan belge ve bilgilerin arrayi

**certificate: string**
: İmzayı oluşturan Base64 kodlanmış sertifika bilgisi.

**certificateName: string**
: İmzayı oluşturan sertifikanın adı.

**certificateIssuer: string**
: İmzayı oluşturan sertifikayı çıkaran yer adı.

**certificateSerialNumber: string**
: İmzayı oluşturan sertifikanın seri numarası. Nitelikli olmayan sertifikalar için bu alan boştur.

**createdAt: string (dateTime)**
: İmzanın oluşturulduğu tarih ve saat.

## Konsol Penceresi
Uygulama içerisindeki yapılan işlemlerin kaydına ve detaylı hata bilgilerine ulaşmak istiyorsanız, konsol penceresinin görüntülenmesini sağlayabilirsiniz. 

Kurulum sonrasında **HKEY_CLASSES_ROOT\sign\shell\open\command** kütük kaydına **/console** parametresinin eklenmesi yeterlidir. Alternatif olarak aşağıdaki bilgileri .reg dosyası olarak kaydedip, çift tıklayarak kaydın yapılmasını sağlayabilirsiniz.

    Windows Registry Editor Version 5.00
    
    [HKEY_CLASSES_ROOT\sign\shell\open\command]
    @="\"C:\\Program Files (x86)\\KolayImza\\AltiKare.KolayImza.exe\" \"%1\ /console""

## C# Kullanım Örneği

Bu örnekte yukarıda anlatılan tüm işlemlerin bütününü içeren file.aspx adlı bir sayfa görmektesiniz. Bu sayfa aracılığı ile imzalanacak bilgileri ve imzalandıktan sonra yapılacak işlemleri kendi taleplerinize göre uyarlayabilirsiniz.



## PHP Kullanım Örneği

Üstteki C# örneğine benzer şekilde aşağıda benzer işlemleri yapan  bir PHP örneğini bulabilirsiniz. PHP ortamının doğası gereği imza cevabı hafızada tutulamadığından geçici olarak sig.json isimli bir dosyaya kaydedilmektedir. 

