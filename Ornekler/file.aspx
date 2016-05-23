<%@ Page Title="" Language="C#" %>
<%@ Import Namespace="System.Threading" %>

<script runat="server" language="c#">

    private string GetUrl(string query)
    {
        return Request.Url.GetLeftPart(UriPartial.Authority) + this.ResolveUrl("~/file.aspx?" + query);
    }

    class EventData
    {
        public EventData()
        {
            this.SignatureReceived = new ManualResetEvent(false);
        }

        public ManualResetEvent SignatureReceived { get; set; }

        public string Data { get; set; }
    }

    static Dictionary<string, EventData> events = new Dictionary<string, EventData>();

    protected override void OnLoad(EventArgs e)
    {
        var url = this.Request.Url;
        var operation = this.Request["op"] ?? "";
        var id = this.Request["id"] ?? "";

        switch (operation)
        {
            case "wait":
                {
                    EventData eventData;

                    this.Response.Write("İmza bekleniyor");
                    this.Response.Write("<scri" + "pt type=\"text/javascript\">");
                    this.Response.Flush();

                    if (events.TryGetValue(id, out eventData))
                    {
                        if (eventData.SignatureReceived.WaitOne(TimeSpan.FromSeconds(3)))
                        {
                            this.Response.Write("alert('");
                            this.Response.Write(eventData.Data);
                            this.Response.Write("');");
                        }
                        else
                        {
                            // refresh page
                            this.Response.Write("window.location = '" + url + "';");
                        }
                    }
                    else
                    {
                        System.Threading.Thread.Sleep(3000);
                    }

                    this.Response.Write("</scri" + "pt>");
                    this.Response.End();

                    break;
                }
            case "request":
                {
                    var request = "{" +
                    "   \"id\":\"" + id + "\"," +
                    "   \"resources\": [" +
                    "       { " +
                    "         \"source\" : \"" + GetUrl("id=" + id + "&op=content") + "\", " +
                    "         \"sourceName\" : \"sample.txt\", " +
                             "\"format\": \"CadesX\"" +
                    "       }" +
                    "   ]," +
                    "   \"responseUrl\": \"" + GetUrl("id=" + id + "&op=response") + "\"" +
                    "}";

                    if (!events.ContainsKey(id))
                    {
                        events[id] = new EventData();
                    }

                    this.Response.ContentType = "application/json";
                    this.Response.Write(request);
                    this.Response.End();
                    break;
                }

            case "content":
                {
                    this.Response.ContentType = "application/octet-stream";
                    this.Response.Write("hello");
                    this.Response.End();
                    //this.Response.TransmitFile(filePath);
                    break;
                }

            case "response":
                {
                    EventData data;

                    if (events.TryGetValue(id, out data))
                    {
                        using (var textReader = new System.IO.StreamReader(this.Request.InputStream))
                        {
                            data.Data = textReader.ReadToEnd();
                        }

                        data.SignatureReceived.Set();
                    }

                    this.Response.End();
                    break;
                }
        }

    }

</script>
<html>
<head>
    <script src="https://code.jquery.com/jquery-git.min.js" type="text/javascript"></script>
</head>
<body>
    <a href="#" class="imzala">İmzala</a>
    <script type="text/javascript">
        $(document).ready(function() {
            $('a.imzala').on('click', function () {
                $('<iframe></iframe>').appendTo('body').attr('src', 'sign://?xs=<%=GetUrl(HttpUtility.UrlEncode("id=123&op=request"))%>');
                window.location.href = '<%=GetUrl("id=123&op=wait")%>';
            });
        });
    </script>
</body>
</html>