//
//  ProfileVM.swift
//  Marko
//
//  Created by Ivan on 26.03.2026.
//

import Foundation

class ProfileVM {
    
    // MARK: - Properties
    
    let auth = AuthService.shared
    
    // MARK: - Outputs
    
    var didLoadingStateChange: ((Bool) -> Void)?
    
    var didErrorOccur: ((String) -> Void)?
    
    var didFinishAction: (() -> ())?
    
    var didProfileTapped: (() -> ())?

    
    // MARK: - Methods
    
    func signOut() {
        
        auth.signOut()
        
    }
    
    func deleteAccount() {
        auth.deleteAccount { result in
            switch result {
            case .failure(let error):
                self.didErrorOccur?(error.localizedDescription)
                
            case .success():
                self.didFinishAction?()
            }
        }
    }
    
    func refundmMoney() {
        
        let refundEntity = Refund()
        refundEntity.refund()
        
    }
}
//
//
//# ProfileVM.swift — подробное объяснение
//
//Создай новый файл `ProfileVM.swift`. Вот что нужно сделать по частям:
//
//---
//
//## 1. Импорт и объявление класса
//
//Импортируй только `Foundation` (UIKit здесь не нужен — это логика, не UI). Объяви класс `ProfileVM`.
//
//---
//
//## 2. Приватное свойство — authService
//
//Внутри класса объяви приватную константу `authService` и сразу присвой ей `AuthService.shared` — это синглтон, через который мы будем вызывать все действия с аккаунтом.
//
//---
//
//## 3. Блок Outputs — три замыкания
//
//Под маркером `// MARK: - Outputs (Closures)` объяви три опциональных замыкания (через `var`, не `let`):
//
//- `didLoadingStateChange` — принимает `Bool`, ничего не возвращает. Будет сообщать экрану: "покажи/скрой спиннер загрузки"
//- `didErrorOccur` — принимает `String`, ничего не возвращает. Будет передавать текст ошибки для показа алерта
//- `didFinishAction` — ничего не принимает и не возвращает. Сигнал координатору: "закрой этот экран"
//
//Все три опциональные (со знаком `?`), потому что их подпишет внешний код позже.
//
//---
//
//## 4. Блок Computed Properties — два вычисляемых свойства
//
//**`userEmail`** — возвращает `String`. Внутри: обратись к `authService.currentUser?.email` и через `??` поставь запасное значение `"Guest User"` если email nil.
//
//**`userInitials`** — возвращает `String`. Внутри используй `guard let` чтобы одновременно извлечь:
//- email из `authService.currentUser?.email`
//- первый символ email через `.first`
//
//Если что-то nil — верни `"?"`. Иначе оберни первый символ в `String(...)` и вызови `.uppercased()`.
//
//---
//
//## 5. Метод signOut()
//
//Простой метод без параметров. Внутри:
//1. Вызови `authService.signOut()`
//2. Вызови `didFinishAction?()` — знак вопроса потому что замыкание опциональное
//
//---
//
//## 6. Метод deleteAccount()
//
//Это самый сложный метод. По шагам:
//
//**Шаг 1** — сразу вызови `didLoadingStateChange?(true)` — сообщи экрану что началась загрузка.
//
//**Шаг 2** — вызови `authService.deleteAccount { }`. Внутри замыкания используй `[weak self]` чтобы избежать утечки памяти.
//
//**Шаг 3** — весь код внутри замыкания оберни в `DispatchQueue.main.async { }` — Firebase вернёт результат в фоновом потоке, а UI обновлять можно только в главном.
//
//**Шаг 4** — внутри `DispatchQueue` первым делом вызови `self?.didLoadingStateChange?(false)` — загрузка завершена.
//
//**Шаг 5** — напиши `switch result` с двумя ветками:
//- `case .success()` → вызови `self?.didFinishAction?()`
//- `case .failure(let error)` → вызови `self?.didErrorOccur?(error.localizedDescription)`
//
//---
//
//Пробуй писать, если застрянешь — показывай! 💪
