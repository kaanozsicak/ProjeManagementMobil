# Roadmap — “Kim Ne Yaptı?” Takım Takip Mobil Uygulaması

Bu uygulamanın amacı, küçük ekiplerde “kim şu an ne yapıyor?”, “hangi işler backlog’da?”, “hangi bug’lar var?”, “neler tamamlandı?” sorularını tek ekranda netleştirmek ve Google Keep’teki dağınık not akışını takım odaklı, anlık güncellenen ve bildirimli bir düzene taşımaktır.

Keep’te zaten çalışan bir zihinsel model var:
Active / Bug & Veri / Logic & Refactoring / Completed ve ayrıca “Fikir Kutusu”.
Uygulama bu modeli bozmadan, sadece daha disiplinli, izlenebilir ve “kimin sorumluluğunda” netliği olan hale getirir.

---

## 1) Ürün Tanımı ve Temel Akış

Uygulamada her şey “Grup (Workspace)” etrafında döner. Bir grup açılır, takım üyeleri katılır, sonra tek bir “Takip Panosu” üzerinden güncellemeler yapılır. Keep’teki gibi emoji’li, kısa ve vurucu bir dil desteklenir ama verinin yapısı artık gerçek bir modeldir: görev, durum, sahip, etiket, öncelik, tarihçe.

Kullanıcı uygulamayı açtığında önce grup seçer. Grup içinde ana ekran, Keep’teki not düzeninin aynısını verir:
“Active/Şu Anda Kimde?” bölümü kişilerin anlık üstlendiği işleri ve durum mesajlarını gösterir.
“Bug & Veri Hataları (Backlog)” bölümü checklist gibi akar.
“Logic & Refactoring (Backend)” ayrı bir liste olarak görünür.
“Tamamlananlar” bir arşiv/başarı hissi oluşturur.
“Fikir Kutusu” ise iş listesine dönüşebilen bir havuzdur (fikir → görevleştir).

---

## 2) MVP Kapsamı (İlk Çalışan Sürüm)

MVP’nin hedefi, 1 hafta içinde “takım içi iletişim karmaşasını azaltan” minimum deneyimi vermektir. MVP’de mutlaka çalışması gereken şeyler:

Bir grup oluşturma ve gruba katılma akışı vardır. Katılım için iki alternatif tasarlanır: davet linki (en pratik) ve OTP (daha kontrollü). Başlangıçta link yeterli olabilir; OTP’yi feature flag gibi açıp kapatabilirsin.

Grup içinde “Takip Panosu” ekranı vardır. Bölümler Keep mantığıyla sabittir ama her bölüm altında gerçek kayıtlar vardır (task item). Her item’ın başlığı, açıklaması, sahibi (bir kişi) ve durumu bulunur. Bug/Logic/Fikir gibi bölümler item’ın türüdür.

“Active” kısmı iki şeyden oluşur: kişinin seçtiği “meşguliyet durumu” (Boşta / Aktif / Toplantıda gibi) ve o anda “üstlendiği görevler”. Yani Active liste aslında “kişiye göre gruplanmış görev görünümü”dür.

Görev ekleme, görev sahiplenme, görev durum değiştirme yapılır. “Tamamlandı”ya atınca Completed listesine düşer.

En kritik fark: Her değişiklik “zaman damgalı” olarak kayda geçer ve herkes aynı şeyi görür. Keep’teki “en son kim neyi değiştirdi” belirsizliği ortadan kalkar.

---

## 3) Veri Modeli (Sade ama Genişlemeye Uygun)

Aşağıdaki model MVP için yeterli ve ileride büyür:

**User**
id, displayName, avatar(optional), createdAt

**Workspace (Group)**
id, name, createdBy, createdAt

**Membership**
workspaceId, userId, role (owner/admin/member), joinedAt

**Presence (Kişi Durumu)**
workspaceId, userId, status (idle/active/busy/away), message (serbest metin), updatedAt

**Item (Görev / Bug / Fikir / Refactor)**
id, workspaceId
type (activeTask/bug/logic/idea)  → pratikte “boardSection”
title, description
assigneeUserId (nullable)
state (todo/doing/done)  → Completed için done
priority (low/med/high) (MVP’de opsiyonel)
tags (array) (MVP’de opsiyonel)
createdBy, createdAt, updatedAt

**ItemActivity (Tarihçe)**
id, itemId, actionType, payload(json), actorUserId, createdAt

Not: Keep’te “Bug & Veri Hataları (Backlog)” gibi bölümler var; biz bunu “type=bug ve state=todo” gibi filtrelerle elde ederiz. “Active/Şu Anda Kimde?” ise “state=doing + assigneeUserId ile kullanıcıya grupla” yaklaşımıdır.

---

## 4) Ekranlar ve UX Akışı

Giriş ekranı sade olmalı: kullanıcı adı gir, devam et (veya Google/Apple login sonraya).

Ardından “Gruplarım” listesi gelir. Buradan grup oluşturulur ya da katılım yapılır.

Grup oluşturma: grup adı, isteğe bağlı ikon/emoji. Oluşturunca davet linki üret.

Katılma: link üzerinden otomatik veya “Kod gir” ekranıyla OTP. OTP akışı “giren kişi -> bekleme -> admin onayı” gibi uzatılabilir ama MVP’de “kodu bilen girer” yeterlidir.

Ana ekran: Keep düzeni. Bölümlerin başlığı net, item satırları kısa ve okunur. Bir item’a tıklayınca detay ekranı açılır; sahip değiştir, durum değiştir, açıklama düzenle, yorum gibi not ekle (MVP’de yorum yerine “activity log” bile yeter).

Kişi listesi: “kim aktif, kim boşta” görünümü. Bir kişiye tıklayınca üstündeki işler.

Bildirim mantığı (MVP): sana atanan yeni iş olunca ve bir işin durumu değişince push olmasa bile “in-app” bildirim rozetleri.

---

## 5) Grup Katılım Tasarımı (Link mi OTP mi?)

Bu projede en sağlam yaklaşım hibrit:

Davet Linki: hızlı onboarding sağlar. Link içinde workspaceId + kısa token bulunur. Token süresi 7 gün gibi ayarlanabilir.

OTP: “paylaşılabilir ama daha kontrollü” bir yöntemdir. Uygulama içinde “Katıl” → “Kod gir” yapılır. Kod workspace’e bağlıdır, süreli üretilir (örn 10 dk). Eğer güvenlik hassas değilse OTP’yi sonraya bırak.

MVP önerisi: link davetle başla. OTP’yi Phase 2’ye koy. Çünkü OTP üretimi + süre + brute force koruması gibi detaylar geciktirir.

---

## 6) Teknoloji Seçimi (Copilot + Claude ile rahat geliştirme)

Mobil tarafta iki mantıklı yol var:

Flutter: tek kod tabanı, hızlı UI, real-time listelerde akıcı. Copilot ile de rahat ilerler.

React Native: zaten JS/TS ekosistemine yakınsan daha hızlı çıkarsın. Firebase ile birleşince MVP çok hızlanır.

Backend için MVP’de en hızlı seçenek Firebase (Auth + Firestore + Cloud Functions) veya Supabase (Auth + Postgres + Realtime). Keep benzeri gerçek zamanlı güncelleme için ikisi de uygundur.

MVP için öneri: Firebase/Firestore. Çünkü “real-time board” işi çok hızlı çözülür.

---

## 7) Fazlar (Sprint Mantığı ile)

### Phase 0 — Ürün Netleştirme (0.5 gün)
Keep notlarındaki bölümleri sabitle: Active, Bug, Logic, Completed, Idea.
Item tiplerini ve state’leri kesinleştir.
“Active”in aslında “doing state + presence” olduğuna karar ver.

Çıktı: ekran çizimi (basit wireframe) ve veri modeli kesinleşmiş olur.

### Phase 1 — Temel Altyapı ve Grup Sistemi (1–2 gün) ✅ TAMAMLANDI
Projeyi oluştur, auth kur (anon/username).
Workspace CRUD.
Membership ve rol (owner/member).
Davet linki ile katılım.

Başarı kriteri: iki telefonla aynı gruba girilip aynı workspace'i görebilmek.

**Tamamlanan işler (25 Aralık 2025):**
- ✅ Flutter projesi + Firebase entegrasyonu
- ✅ Anonymous Auth ile kullanıcı adı girişi
- ✅ User, Workspace, Membership, Invite modelleri
- ✅ Workspace oluşturma ve listeleme
- ✅ Davet kodu üretme ve paylaşma
- ✅ Davet kodu ile workspace'e katılma
- ✅ Firestore security rules
- ✅ Riverpod state management
- ✅ GoRouter navigation

### Phase 2 — Board (Keep Replika) MVP (2–3 gün) ✅ TAMAMLANDI
Board ekranı bölümleriyle gelir.
Item ekleme/düzenleme/silme.
Assign, state değiştirme.
Completed görünümü.

Başarı kriteri: Keep'teki bir not, uygulamada birebir yaşatılabiliyor.

**Tamamlanan işler (25 Aralık 2025):**
- ✅ Item model (type: activeTask/bug/logic/idea, state: todo/doing/done, priority, assignee)
- ✅ Item repository (CRUD, state transitions, assign)
- ✅ Item providers (Riverpod StateNotifier, streams)
- ✅ Board ekranı (Keep-style 4 bölüm: Active, Bug, Logic, Fikir)
- ✅ Item oluşturma dialog (tür, başlık, açıklama, öncelik, atama)
- ✅ Item detay dialog (düzenleme, silme, hızlı işlemler)
- ✅ Completed items bottom sheet (tarihle gruplu)
- ✅ Quick actions (Başla, Tamamla, state transitions)
- ✅ Firestore security rules for items collection
- ✅ Real-time updates via Firestore streams

### Phase 3 — Presence ve "Active/Şu Anda Kimde?" (1–2 gün) ✅ TAMAMLANDI
Kişi durumları (idle/active/busy) ve serbest mesaj.
Active bölümünde kişiye göre doing işler.

Başarı kriteri: "Burak boşta / Mama yiyor" gibi durumlar canlı görünür ve aktif işler kişiye bağlanır.

**Tamamlanan işler (25 Aralık 2025):**
- ✅ Presence model (status: idle/active/busy/away + serbest mesaj)
- ✅ Presence repository (CRUD, real-time streams)
- ✅ Presence providers (StateNotifier, presence map)
- ✅ "Şu Anda Kimde?" görünümü (kullanıcıya göre gruplu doing items)
- ✅ Durum güncelleme UI (status seçici + mesaj + hızlı öneriler)
- ✅ Board ekranına entegrasyon (üstte presence widget)
- ✅ Firestore security rules for presence collection

### Phase 4 — Aktivite Log'u ve Basit Bildirim (1–2 gün) ✅ TAMAMLANDI
Her item değişikliğine activity kaydı.
In-app bildirim ekranı (son 50 hareket).
İsteğe bağlı push: "sana iş atandı" (phase 4.5).

Başarı kriteri: "kim neyi değiştirdi" sorusu uygulamada tek tıkla cevaplanır.

**Tamamlanan işler (25 Aralık 2025):**
- ✅ ItemActivity model (9 action type: created, deleted, stateChanged, assigned, etc.)
- ✅ Activity repository (log methods, real-time streams)
- ✅ Activity providers (grouped by date, unread count)
- ✅ "Son Hareketler" ekranı (/workspace/:id/activities)
- ✅ Board'da activity butonu (badge ile)
- ✅ Item CRUD'a otomatik activity logging entegrasyonu
- ✅ Firestore security rules for activities collection

### Phase 5 — Fikir Kutusu → Görevleştir (1 gün) ✅ TAMAMLANDI
Idea item'ı "task/bug/logic"e dönüştürme aksiyonu.
Idea havuzu filtreleme.

Başarı kriteri: fikirler kaybolmaz, sprint başlamadan görevleşir.

**Tamamlanan işler (25 Aralık 2025):**
- ✅ "Görevleştir" UI (Item detail dialog'da idea için özel bölüm)
- ✅ Hızlı dönüştürme butonları (🎯 Görev, 🐛 Bug, ⚙️ Logic)
- ✅ Fikir Kutusu bölümü özel tasarım (_IdeaCard)
- ✅ Board'da idea için bilgi banner'ı
- ✅ convertType ile activity logging entegrasyonu

---

## 8) Non-Functional Gereksinimler (MVP’de hafif, ama kritik)

Gerçek zamanlı senkronizasyon stabil olmalı. Aynı item’a iki kişi dokunursa en azından “son yazan kazanır” ve activity log’da görünür.

Offline: tamamen offline şart değil ama listeyi cache’lemek iyi olur. En azından uygulama açılınca boş ekran vermemeli.

Performans: Board ekranında gereksiz re-render’ı azalt. Uzun listeler için pagination veya lazy load.

Güvenlik: workspaceId üzerinden erişim kuralları. Üye olmayan veri görmemeli. Invite token’ları süreli olmalı.

---

## 9) Copilot Agent + Claude Opus 4.5 için Uygulama Üretim Stratejisi

Bu projeyi agent ile geliştirirken, her adımı “net görev + kabul kriteri + küçük PR” olarak bölmek en iyi sonuç verir.

Önerilen çalışma düzeni:
Her sprint başında agent’a “bu fazın hedefi”ni ve “done tanımı”nı ver.
Agent’tan önce veri modelini, sonra ekranları, en son edge-case’leri istemeyi alışkanlık yap.
Her önemli ekranda en az bir test senaryosu yazdır (unit değilse bile “manual QA checklist”).

Agent prompt şablonu:
“Şu feature’ı ekle: …  
Kapsam dışı: …  
Kabul kriterleri: …  
Dosya yapısı: …  
Kod stili: …  
Eksik gördüğün riskler: …”

Örnek kabul kriteri formatı:
“İki cihaz aynı gruba girince, bir cihaz item eklediğinde diğer cihaz 1 sn içinde görmeli.”

---

## 10) İlk Issue Listesi (Repo Açılışı İçin Hazır Metin)

Bu bölüm, GitHub Issues’a direkt kopyalanabilir.

Issue 1: Proje iskeleti ve temel routing (Auth + Workspace list)
Issue 2: Workspace oluşturma ve davet linki üretme
Issue 3: Davet linki ile gruba katılım ve membership kaydı
Issue 4: Board ekranı (bölümlü liste) ve Firestore query’leri
Issue 5: Item CRUD + assign + state geçişleri
Issue 6: Presence modeli ve status güncelleme UI
Issue 7: “Active / Şu Anda Kimde?” görünümü (user grouping)
Issue 8: Activity log yazımı ve “Son hareketler” ekranı
Issue 9: Idea item → task/bug/logic dönüşümü
Issue 10: Güvenlik kuralları (Firestore rules / RLS)

---

## 11) Gelecek (MVP Sonrası Güzel Ekstralar)

Sürükle-bırak ile item taşımak (Kanban hissi).
Sprint kavramı (iteration) ve “Sıradakiler” kuyruğu.
Etiketler, filtreler, arama ve “debounce 500ms” gibi Keep’teki arama benzeri.
Takvim entegrasyonu (deadline).
Webhook/Discord bildirimi.
“Şablonlar”: CTI Platform gibi proje şablonunu tek tıkla kurmak.

---

## Son Not

Bu uygulama, “task manager” olmaktan çok “takım içi netlik ekranı” olmalı. Keep’in çalışmasının sebebi basitliği; bu projede kazanman gereken şey de aynı basitliği koruyarak gerçek zamanlılık, sahiplik ve tarihçe eklemek.

