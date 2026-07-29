# Prompt para o Claude Code — próximos passos do TimeShift

Cole o conteúdo abaixo (a partir de "## Contexto") como prompt inicial de uma sessão do Claude Code dentro da pasta do projeto (`/Users/gabrielamaral/Documents/Projetos/TimeShift`).

---

## Contexto

Este é o TimeShift, um app iOS (alvo: iOS 27 / Xcode 27 / Swift 6) em SwiftUI. A ideia central: uma pilha de cards, um por cidade, cada um mostrando a hora local via um preenchimento horizontal (0h–24h). Arrastar o preenchimento de qualquer card atualiza um relógio compartilhado (`TimeShiftViewModel.referenceDate`); todos os outros cards recalculam a própria hora a partir desse mesmo instante.

Leia `ARCHITECTURE.md` na raiz do projeto antes de começar — ele documenta a estrutura de pastas, o modelo de dados e as decisões de arquitetura.

Arquivos centrais para esta tarefa:

- `TimeShift/TimeShiftApp/App/ContentView.swift` — tela raiz: `ScrollView` + `VStack` + `ForEach(cities)`, toolbar com botão de adicionar cidade (abre `CitySearchView` via `.sheet`).
- `TimeShift/Views/Cards/CityCardView.swift` — o card individual. Tem um `DragGesture(minimumDistance: 0)` (controlado por `isEnabled: isInteractive`) cobrindo o card inteiro, usado para arrastar o preenchimento/hora. Já recorta o conteúdo com `.clipShape` antes do `.glassEffect` (bug de vazamento de canto já corrigido — não mexer nisso sem necessidade).
- `TimeShift/Views/Cards/CityCardBackground.swift` — gradiente de fundo interpolado pela fração do dia.
- `TimeShift/Views/AddCity/CitySearchView.swift` — sheet de busca/adição de cidade. Hoje usa `TimeZone.knownTimeZoneIdentifiers` como fonte local (sem rede).
- `TimeShift/ViewModels/TimeShiftViewModel.swift` — `@Observable`, expõe `referenceDate`, `draggingCityID`, `fraction(for:)`, `updateReferenceDate(draggedCity:toFraction:)`, `endDragging()`.
- `TimeShift/Models/WorldCity.swift` — `@Model` do SwiftData: `id`, `name`, `timeZoneIdentifier`, `sortOrder`, `isPrimary`.
- `TimeShift/Utilities/TimeZone+Formatting.swift` — formatação de hora (`Date.FormatStyle`, fixo em 24h por decisão do produto — **não reintroduzir toggle de 12h/24h**).

O estado atual do `ContentView.swift` é o baseline que compila e funciona (sem modo edição, sem reorder, sem swipe). **Confirme que o projeto compila e roda antes de fazer qualquer mudança**, para ter certeza de onde está partindo.

## Lições da sessão anterior — leia antes de mexer em reorder/swipe

Já tentamos implementar reordenação com uma API (`reorderable()` / `reorderContainer(for:isEnabled:move:)` / `ReorderDifference`) descrita em posts de blog sobre o iOS 27, sem confirmar contra a documentação oficial da Apple ou o SDK instalado de verdade. Resultado: erros recorrentes de `"The compiler is unable to type-check this expression in reasonable time"`, mesmo depois de quebrar a view em subviews menores. Isso normalmente indica um dos dois problemas:

1. A API não existe com essa assinatura no SDK instalado (o compilador tenta resolver overloads contra símbolos parecidos de todo o SDK e trava), ou
2. Closures grandes/genéricas demais no mesmo corpo de `body`.

**Antes de usar qualquer API nova do iOS 27 por nome** (`reorderable`, `reorderContainer`, `ReorderDifference`, `swipeActionsContainer`, etc.), confirme que ela existe no SDK instalado — via autocomplete do Xcode, Quick Help (⌥+clique) ou "Jump to Definition". Se não existir ou o comportamento for incerto, prefira a API estável e testada.

## Tarefas

### 1. Facilitar o scroll da lista de cards

Hoje, rolar a tela pode estar competindo com o `DragGesture(minimumDistance: 0)` de `CityCardView`, que cobre o card inteiro e reconhece o toque imediatamente (distância mínima zero), disputando com o gesto de pan do `ScrollView` mesmo em arrastes verticais.

Investigue e corrija. Abordagens possíveis (escolha a que funcionar melhor na prática, teste no simulador):

- Aumentar `minimumDistance` do `DragGesture` (ex.: 10–15pt) para dar chance ao reconhecedor de scroll de vencer arrastes predominantemente verticais.
- Dentro de `onChanged`, só tratar o gesto como "arrastar hora" quando `abs(translation.width) > abs(translation.height)`; caso contrário, ignorar a atualização (mas lembre que, uma vez que o `DragGesture` reivindicou o toque, ele não devolve o gesto ao `ScrollView` no meio do caminho — o ajuste de `minimumDistance` costuma ser o que resolve de fato).
- Se nada disso for suficiente, considere restringir a área de toque do gesto (ex.: só a metade inferior do card, deixando uma faixa "neutra" pro scroll) ou usar `.simultaneousGesture` combinado com um teste de direção.

Critério de aceite: dá pra rolar a lista normalmente tocando em qualquer parte de um card, sem que o card comece a "preencher" sozinho por causa do gesto de scroll. E o arraste horizontal intencional continua funcionando para mudar a hora.

### 2. Reordenar cidades no modo edição

Adicionar um botão "Editar"/"Concluir" na toolbar (`ContentView`) que ativa um `isEditing: Bool`. Em modo edição:

- O `DragGesture` de horário de cada card deve ficar desabilitado (`CityCardView` já tem o parâmetro `isInteractive` pronto para isso — passe `isInteractive: !isEditing`).
- O usuário deve poder arrastar para reordenar as cidades.

**Recomendação, dado o histórico de falhas de compilação**: migre a lista de `ScrollView { VStack { ForEach ... } }` para um `List`, e use `.onMove(perform:)` (API estável desde sempre) dentro de um `.environment(\.editMode, ...)` ou controlado por `EditButton`/um botão custom ligado a `isEditing`. Dá pra manter a aparência visual atual (glass, cantos arredondados, espaçamento) estilizando as linhas do `List` com `.listRowBackground(Color.clear)`, `.listRowSeparator(.hidden)`, `.listRowInsets(...)` etc. — o `List` não precisa parecer uma lista "de sistema".

Se preferir tentar a API nova (`reorderable()`/`reorderContainer`) porque confirmou que ela existe e compila no ambiente instalado, tudo bem — mas faça isso incrementalmente, compilando após cada passo pequeno, e com fallback pronto para o `List`/`.onMove` caso volte a travar o type-checker.

A ordem final tem que ser persistida no `sortOrder` de cada `WorldCity` (é o que o `@Query(sort: \WorldCity.sortOrder)` do `ContentView` lê).

Critério de aceite: em modo edição, dá pra arrastar um card para uma nova posição, soltar, sair do modo edição, fechar e reabrir o app — a ordem se mantém.

### 3. Apagar cidade com swipe

No mesmo modo edição (ou mesmo fora dele, se fizer mais sentido de UX — decida e justifique brevemente no resumo final), permitir apagar uma cidade deslizando o card (swipe-to-delete).

Se a Tarefa 2 migrar para `List`, isso sai quase de graça com `.swipeActions(edge: .trailing, allowsFullSwipe: true) { Button(role: .destructive) { ... } { Label("Apagar", systemImage: "trash") } }` — API estável, disponível desde o iOS 15.

Se decidir manter a lista fora de um `List`, use a API `swipeActionsContainer` do iOS 27 mencionada no `ARCHITECTURE.md`, mas só depois de confirmar que ela existe no SDK (mesma ressalva da Tarefa 2).

Critério de aceite: dá pra deslizar um card e apagar a cidade, com confirmação visual (cor de destrutivo, ícone de lixeira). A cidade some da lista e do SwiftData.

### 4. Conectar a uma API gratuita de cidades

Hoje `CitySearchView` usa `TimeZone.knownTimeZoneIdentifiers` (nomes de fuso, não de cidade de verdade, sem rede). Troque — ou complemente — por uma busca de verdade usando a **API de geocoding do Open-Meteo**, que é gratuita, não exige chave/API key e já retorna o fuso horário IANA de cada cidade:

```
GET https://geocoding-api.open-meteo.com/v1/search?name={termo}&count=10&language=pt&format=json
```

Exemplo de resposta (testado e confirmado funcionando):

```json
{
  "results": [
    {
      "id": 3169070,
      "name": "Rome",
      "latitude": 41.89193,
      "longitude": 12.51133,
      "country": "Italy",
      "country_code": "IT",
      "timezone": "Europe/Rome",
      "population": 2318895,
      "admin1": "Lazio"
    }
  ]
}
```

O campo `timezone` já é o identificador IANA que `WorldCity.timeZoneIdentifier` espera — não precisa de nenhuma tradução.

Implementação sugerida:

- `struct GeocodingResponse: Decodable { let results: [GeocodingResult]? }` e `struct GeocodingResult: Decodable { let id: Int; let name: String; let country: String?; let admin1: String?; let timezone: String }` (nomes de campo já batem com o JSON, então `Decodable` automático funciona sem `CodingKeys`).
- Uma função `async throws` que monta a URL (`URLComponents`, com o texto de busca no query item `name`), faz `URLSession.shared.data(from:)`, decodifica com `JSONDecoder` e retorna `[GeocodingResult]`.
- Em `CitySearchView`, troque a lista estática por essa busca, disparada com um debounce simples no `.onChange(of: searchText)` (ex.: `Task` cancelável, esperando ~300ms antes de disparar a request, pra não bater na API a cada tecla).
- Trate estados de carregando/erro/sem resultados (`ProgressView`, mensagem de erro, `ContentUnavailableView`).
- Ao selecionar um resultado, crie o `WorldCity` com `name` e `timezone` vindos da API, do jeito que `addCity(identifier:)` já faz hoje.
- Mantenha algum fallback razoável se a rede falhar (ex.: mensagem de erro amigável; não precisa manter o dataset local de `TimeZone.knownTimeZoneIdentifiers` a menos que ache que vale a pena como fallback offline — decisão sua).

Critério de aceite: buscar "Tóquio", "Rome", "New York" etc. retorna cidades de verdade (não só identificadores de fuso), com nome e país legíveis, e adiciona a cidade certa com o fuso certo.

### 5. Auditoria de UI/UX com a skill `swiftui-pro`

Depois de implementar as tarefas 1–4 e confirmar que o projeto compila e roda, rode a skill **`swiftui-pro`** (disponível neste ambiente) para revisar o app inteiro em relação a UI/UX, uso de cores e contraste — em especial:

- Contraste do texto sobre o gradiente de `CityCardBackground` nos horários mais claros do dia (meio-dia, nascer/pôr do sol), onde o fundo fica bem claro.
- Consistência visual entre o modo normal e o modo edição.
- Feedback visual de affordances (o que é arrastável, o que é deslizável, o que é tocável).

Aplique as correções que fizerem sentido. Para qualquer sugestão da skill que você decidir **não** aplicar, anote o motivo no resumo final.

## Como reportar no final

Feche com um resumo curto: o que foi feito em cada uma das 5 tarefas, quais decisões de arquitetura você tomou (principalmente se migrou para `List` na tarefa 2/3), e se algo ficou pendente ou precisou de um approach diferente do sugerido aqui — e por quê.
